#!/bin/bash

BINDIR="$(dirname "$(readlink -f "$0")")"
source "$BINDIR"/backup.conf

# Check configuration
if [ -z "$BACKUPHOST" ]; then
	echo "BACKUPHOST missed in config file"
	exit 1
fi

if [ -z "$BACKUPDIR" ]; then
	echo "BACKUPDIR missed in config file"
	exit 1
fi

if [ -z "$BACKUPUSER" ]; then
	echo "BACKUPUSER missed in config file"
	exit 1
fi

if [ -z "$BACKUPSTATEFILE" ]; then
	echo "BACKUPSTATEFILE missed in config file"
	exit 1
fi

if [ -z "$BACKUPCOUNT" ]; then
	echo "BACKUPCOUNT missed in config file"
	exit 1
fi

if [ -z "$BACKUP_DIRS_LIST" ]; then
	echo "BACKUP_DIRS_LIST missed in config file"
	exit 1
fi

if ! ping -q -c 1 "$BACKUPHOST" > /dev/null; then
	echo "Backup host not reacheable"
	exit 1
fi

echo "$(date): Start remote preparation moves"

# Prepare destination
cat "$BINDIR"/backup.conf "$BINDIR"/remote_script_prepare.lib | ssh -T "$BACKUPUSER"@"$BACKUPHOST"
retcode=$?
if [ $retcode -eq 99 ]; then
	echo "Remote execution cancelled"
	exit 2
elif [ $retcode -ne 0 ]; then
	echo "Error connect backup host $retcode"
	exit 3
fi

# Build up excluded files list
EXCLUDED_PARAM=("--exclude-from=$BINDIR"/backup.exclude.defaults)

for file in "${RSYNC_EXCLUDE_FILES[@]}"; do
	EXCLUDED_PARAM+=("--exclude-from=$file")
done

# Do sync
for dir in "${BACKUP_DIRS_LIST[@]}"; do
	echo "$(date): Sync $dir"
	rsync $RSYNC_PARAM -a --delete --delete-excluded \
			--whole-file --numeric-ids --relative "$dir" \
			${EXCLUDED_PARAM[@]} \
			"$BACKUPUSER"@"$BACKUPHOST":"$BACKUPDIR"/backup_01
	retcode=$?
	if [ $retcode -eq 24 ]; then
		echo "Ignore vanished files warning"
	elif [ $retcode -ne 0 ]; then
		echo "Error $retcode in backup of $dir"
		exit 4
	fi
done

echo "$(date): Execute finish script"
cat "$BINDIR"/backup.conf "$BINDIR"/remote_script_finish.lib | ssh -T "$BACKUPUSER"@"$BACKUPHOST"
retcode=$?
if [ $retcode -eq 99 ]; then
	echo "Something wrong on backup commit"
	exit 5
fi

echo "$(date): Finish"
exit 0
