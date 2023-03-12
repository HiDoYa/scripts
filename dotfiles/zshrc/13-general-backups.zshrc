# HIDE: Remove rclone files past some number of retention days
function remove_old_backups()
{
	RCLONE_LOCATION=$1
	RETENTION_DAYS=$2

	# Remove old backups
	rclone lsd $RCLONE_LOCATION | while read -r line; do
		FILE_DATE=$(echo $line | awk '{print $2}')
		FILE_NAME=$(echo $line | awk '{print $5}')

		FILE_DATE_UNIX=$(date -j -f "%F" $FILE_DATE +%s) 
		CURRENT_DATE_UNIX=$(date +%s)

		DIFF=$(expr $CURRENT_DATE_UNIX - $FILE_DATE_UNIX)
		DIFF_IN_DAYS=$(expr $DIFF / 60 / 60 / 24)

		if [[ $DIFF_IN_DAYS > $RETENTION_DAYS ]]; then
			echo "Deleting file $file"
			rclone delete $RCLONE_LOCATION/$file
		fi
	done
}

# Backup secrets to google drive
function sbackup()
{
	RETENTION_DAYS=365
	RCLONE_LOCATION=MainDrive:/Backup/secrets
	TEMP_DIRNAME=$(date +%Y-%m-%d-%H:%M)

	mkdir /tmp/$TEMP_DIRNAME

	SECRET_LOCATIONS=(
		$SCRIPTS_DIR/dotfiles/zshrc \
		$HOME/Documents/credentials \
		$HOME/.config/rclone \
		$HOME/.kube \
		$HOME/.ssh \
		$HOME/.aws
	)

	for loc in ${SECRET_LOCATIONS[@]}; do
		sudo cp -r $loc /tmp/$TEMP_DIRNAME
	done

	# Move into drive
	sudo rclone copy /tmp/$TEMP_DIRNAME $RCLONE_LOCATION/$TEMP_DIRNAME
	echo "Finished backing up $TEMP_DIRNAME"
	sudo rm -rf /tmp/$TEMP_DIRNAME

	# Remove old backups
	remove_old_backups $RCLONE_LOCATION $RETENTION_DAYS
}

# Backup pkg to google drive
function pkgbackup()
{
	RETENTION_DAYS=365
	RCLONE_LOCATION=MainDrive:/Backup/pkg/$PC_PURPOSE
	TEMP_DIRNAME=$(date +%Y-%m-%d-%H:%M)

	mkdir /tmp/$TEMP_DIRNAME

	# Save to files
	gem list > /tmp/$TEMP_DIRNAME/gem.txt
	brew leaves > /tmp/$TEMP_DIRNAME/brew.txt
	brew list --cask > /tmp/$TEMP_DIRNAME/brew-cask.txt
	ls $(npm root -g) > /tmp/$TEMP_DIRNAME/npm.txt
	pip3 freeze > /tmp/$TEMP_DIRNAME/pip.txt

	# Move into drive
	sudo rclone copy /tmp/$TEMP_DIRNAME $RCLONE_LOCATION/$TEMP_DIRNAME
	echo "Finished backing up $TEMP_DIRNAME"
	sudo rm -rf /tmp/$TEMP_DIRNAME

	# Remove old backups
	remove_old_backups $RCLONE_LOCATION $RETENTION_DAYS
}