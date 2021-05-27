#!/bin/sh
cd "$(dirname "$(readlink -f "$0")")"

# Convert rsync-homedir-excludes list
TARGET=rsync-homedir-excludes-converted
rm "$TARGET" 2>/dev/null

# Update repo
cd rsync-homedir-excludes
git pull
cd ..

while read LINE; do
	FIRSTCHAR="${LINE:0:1}"
	if [ -z "$FIRSTCHAR" ] || [ "$FIRSTCHAR" == '#' ]; then
		echo "$LINE" >> "$TARGET"
	elif [ "$FIRSTCHAR" == '/' ]; then
		echo '/home/*'"$LINE" >> "$TARGET"
	else
		echo '/home/*/'"$LINE" >> "$TARGET"
	fi
done < rsync-homedir-excludes/rsync-homedir-excludes.txt
