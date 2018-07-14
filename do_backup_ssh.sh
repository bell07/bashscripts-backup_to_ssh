#!/bin/sh

BINDIR="$(dirname $0)"
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

# Prepare destination
echo "$(cat "$BINDIR"/backup.conf "$BINDIR"/remote_script_prepare.lib)" |
		ssh -T "$BACKUPUSER"@"$BACKUPHOST"
retcode=$?
if [ $retcode -eq 99 ]; then
	echo "Remote execution cancelled"
elif [ $retcode -ne 0 ]; then
	echo "Error connect backup host $retcode"
fi

# Do sync
for dir in ${BACKUP_DIRS_LIST[@]}; do
	rsync $RSYNC_PARAM -a --delete --delete-excluded \
			--numeric-ids --relative "$dir" \
			--exclude-from="$BINDIR"/backup.exclude \
			"$BACKUPUSER"@"$BACKUPHOST":"$BACKUPDIR"/backup_1
	retcode=$?
	if [ $retcode -ne 0 ]; then
		echo "Error in backup of $dir"
		exit 1
	fi
done


echo "$(cat "$BINDIR"/backup.conf "$BINDIR"/remote_script_finish.lib)" |
		ssh -T "$BACKUPUSER"@"$BACKUPHOST"
retcode=$?
if [ $retcode -eq 99 ]; then
	echo "Something wrong on backup commit"
	exit 1
fi

exit 0
