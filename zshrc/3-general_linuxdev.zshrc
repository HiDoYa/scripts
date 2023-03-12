# Initialize and start linux dev. Takes mount path argument
function linuxup()
{
	ABS_PATH=$HOME/Downloads
	if [[ $1 ]] ABS_PATH=$(realpath $1)
	export MOUNT_PATH=$ABS_PATH

	VAGRANT_PATH=$SCRIPTS_DIR/ubuntu-sandbox
	IS_INSIDE=$(insidedir $VAGRANT_PATH)

	if [[ ! $IS_INSIDE ]] pushd $VAGRANT_PATH > /dev/null

	# Mount changed
	if [[ $ABS_PATH != $(cat mounted.txt) ]] then
		echo $ABS_PATH > mounted.txt
		vagrant reload
	else
		# Mount did not change
		# Just ensure it is running
		vagrant up
	fi

	vagrant ssh-config > ssh.config
	if [[ ! $IS_INSIDE ]] popd > /dev/null
}

# Show current status of linux dev
function linuxls()
{
	IS_INSIDE=$(insidedir $LINUX_DIR)

	if [[ ! $IS_INSIDE ]] pushd $LINUX_DIR > /dev/null
	vagrant status linux-dev 
	if [[ ! $IS_INSIDE ]] popd > /dev/null
}

# SSH into linux dev
function linuxssh()
{
	IS_INSIDE=$(insidedir $LINUX_DIR)

	if [[ ! $IS_INSIDE ]] pushd $LINUX_DIR > /dev/null
	vagrant ssh linux-dev 
	if [[ ! $IS_INSIDE ]] popd > /dev/null
}

# Clean up and destroy linux dev
function linuxdown()
{
	IS_INSIDE=$(insidedir $LINUX_DIR)

	if [[ ! $IS_INSIDE ]] pushd $LINUX_DIR > /dev/null
	MOUNT_PATH=$(cat mounted.txt) vagrant destroy -f linux-dev
	if [[ ! $IS_INSIDE ]] popd > /dev/null
}

# Note requires vagrant-scp plugin (vagrant plugin install vagrant-scp)
# Copy file onto linux dev. Takes copy file argument
function linuxcp()
{
	if [[ ! $1 ]] then
		echo "You must specify a directory/file"
		exit
	fi

	IS_INSIDE=$(insidedir $LINUX_DIR)

	ABS_PATH=$(realpath $1)
	if [[ ! $IS_INSIDE ]] pushd $LINUX_DIR > /dev/null
	vagrant scp linux-dev:.
	if [[ ! $IS_INSIDE ]] popd > /dev/null
}

# Get status of linux dev
function linuxst()
{
	IS_INSIDE=$(insidedir $LINUX_DIR)

	if [[ ! $IS_INSIDE ]] pushd $LINUX_DIR > /dev/null
	vagrant status
	if [[ ! $IS_INSIDE ]] popd > /dev/null
}

# Open linux mount path in vscode
function linuxcode()
{
	code --remote ssh-remote+linux-dev /home/vagrant/mount
}

# Quick start linux up
function linuxqup()
{
	if [[ $1 ]]; then
		linuxup $1 && linuxcode
	else
		echo "Specfiy directory"
	fi
}
