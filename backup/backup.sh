#!/bin/bash

# Usage:
# sudo su root
# sudo -i -u hiroyagojo ./Code/scripts/backup.sh

# Used to store pkg backups for home vs work
RCLONE_CONF=$HOME/.config/rclone/rclone.conf

# Ensure brew is sourced
eval "$(/opt/homebrew/bin/brew shellenv)"

# Remove rclone files past some number of retention days
function remove_old_backups()
{
	RCLONE_LOCATION=$1
	RETENTION_DAYS=$2

	# Remove old backups
	rclone lsd $RCLONE_LOCATION --config $RCLONE_CONF | while read -r line; do
		FILE_DATE=$(echo $line | awk '{print $2}')
		FILE_NAME=$(echo $line | awk '{print $5}')

		FILE_DATE_UNIX=$(date -j -f "%F" $FILE_DATE +%s) 
		CURRENT_DATE_UNIX=$(date +%s)

		DIFF=$(expr $CURRENT_DATE_UNIX - $FILE_DATE_UNIX)
		DIFF_IN_DAYS=$(expr $DIFF / 60 / 60 / 24)

		if [[ $DIFF_IN_DAYS -gt $RETENTION_DAYS ]]; then
			echo "Deleting file $FILE_NAME"
			rclone delete $RCLONE_LOCATION/$FILE_NAME --config $RCLONE_CONF
		fi
	done
}

# Backup secrets to google drive
function sbackup()
{
    echo "Backing up secrets"
	RETENTION_DAYS=365
	RCLONE_LOCATION=MainDrive:/Backup/secrets
	TEMP_DIRNAME=$(date +%Y-%m-%d-%H:%M)

	mkdir /tmp/$TEMP_DIRNAME

	SECRET_LOCATIONS=(
		$HOME/Code/scripts/dotfiles/zshrc \
		$HOME/Documents/credentials \
		$HOME/.config \
		$HOME/.ssh
		$HOME/.aws
	)

	for loc in ${SECRET_LOCATIONS[@]}; do
		cp -r $loc /tmp/$TEMP_DIRNAME
	done

	# Move into drive
	rclone copy /tmp/$TEMP_DIRNAME $RCLONE_LOCATION/$TEMP_DIRNAME --config $RCLONE_CONF
	echo "Finished backing up $TEMP_DIRNAME"
	rm -rf /tmp/$TEMP_DIRNAME

	# Remove old backups
	remove_old_backups $RCLONE_LOCATION $RETENTION_DAYS

    echo "Finished backing up secrets"
}

# Backup pkg to google drive
function pkgbackup()
{
    echo "Backing up pkgs"

	RETENTION_DAYS=365
	RCLONE_LOCATION=MainDrive:/Backup/pkg
	TEMP_DIRNAME=$(date +%Y-%m-%d-%H:%M)

	mkdir /tmp/$TEMP_DIRNAME

	# Save to files
	gem list > /tmp/$TEMP_DIRNAME/gem.txt
	brew leaves > /tmp/$TEMP_DIRNAME/brew.txt
	brew list --cask > /tmp/$TEMP_DIRNAME/brew-cask.txt
	ls $(npm root -g) > /tmp/$TEMP_DIRNAME/npm.txt
	pip3 freeze > /tmp/$TEMP_DIRNAME/pip.txt

	# Move into drive
	rclone copy --config $RCLONE_CONF /tmp/$TEMP_DIRNAME $RCLONE_LOCATION/$TEMP_DIRNAME
	echo "Finished backing up $TEMP_DIRNAME"
	rm -rf /tmp/$TEMP_DIRNAME

	# Remove old backups
	remove_old_backups $RCLONE_LOCATION $RETENTION_DAYS
    echo "Finished backing up pkgs"
}

# Call both backups
sbackup
pkgbackup