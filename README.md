# backup_to_ssh
My push backup script inspired by rsnapshot

I wrote it because I did not found a way to initiate the rsnapshot from client to the server.
rsnapshot way is to collect backups from clients that does not work as cron job for me because my client is offline most times.
rsnapshot on client requires mounted server directory, and the incremental overhead is slow.

This script does initial some magic on server trough ssh connection, then do the rsync, and get some statistics trough ssh again.

# How to use - All on client
## setup the backup.conf (see backup.conf.example)
```
# copy this file to backup.conf and adjust your setting
# The syntax is your shell

# Backup is pushed to this host
BACKUPHOST=backup_host

# Remote dir on remote host the backup is created
BACKUPDIR=/mnt/usbdisk/backup/my_client

# Your user on remote host
BACKUPUSER=root

# Statefile on server to resume processing if interrupted
BACKUPSTATEFILE="$BACKUPDIR"/"backup_state.tmp"

## Additional parameters for rsync command
#RSYNC_PARAM="-zc"  # Compress + full check by checksum
RSYNC_PARAM="-z"    # Compress + default quick check

## Backup local dirs are backed up
## Note, some subdirs could be excluded in exclude file
BACKUP_DIRS_LIST=(
	/boot
	/etc
	/home
	/usr/local
	/var/lib
)
```

## setup the backup.exclude (see backup.exclude.example)
```
# Usual rsync exclude file

# Exclude by regular expression
*/[Cc]ache/*
*/[.][Cc]ache/*

*/[Tt]emp/*
*/[.][Tt]emp/*

*/[Tt]mp/*
*/[.][Tt]mp/*

*/[Tt]humbnails/*
*/[.][Tt]humbnails/*

*/[Tt]rash/*
*/[.][Tt]rash/*

*/[Ll]ogs/*
*/[.][Llt]ogs/*

# By file
/home/*/.config/syncthing/

/home/*/.minetest/debug.txt
/home/*/Downloads

/var/lib/mlocate
/var/lib/systemd/coredump

```

## Call the do_backup_ssh.sh script
To avoid password request I recomend to set up SSH-Keys authentification
The script is designed to run from client on cron.daily basis (using anacron)

Result on Server:
On server you get the $BACKUPDIR/backup_* subdirectories with hard-linked full backups like rsnapshot does it, up to BACKUPCOUNT copies.

For newbies: Each of the dirs contains all files, but unchanged files consume the space once because of hardlink.
