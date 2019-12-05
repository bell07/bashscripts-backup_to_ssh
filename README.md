# backup_to_ssh
My push backup script inspired by rsnapshot

I wrote this scripts because I did not found a way to initiate the rsnapshot from client to the server.
rsnapshot way is to collect backups initiated server-site. That does not work for me since my client is offline most times if the cron job does run in server.
If rsnapshot runs on client the server directory needs to be mounted, and the incremental comarsion overhead is slow because comparing is done on client this way.

backup_to_ssh does initial some magic on server trough ssh connection, then do the rsync, and get some statistics trough ssh again.

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
To be able to run the script as cron job in background the SSH-Keys authentification should be set up.
The script is designed to run from client on cron.daily basis (using anacron)

Result on Server:
On server you get the $BACKUPDIR/backup_* subdirectories with hard-linked full backups up to BACKUPCOUNT copies. It is the same way as rsnapshot does. For data restore just copy files you need from the backup subdirectory.

For newbies: Each of the dirs contains all files, but unchanged files consume the space once because of hardlink.
