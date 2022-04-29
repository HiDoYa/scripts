# Define colors
GREEN=$(tput -Txterm setaf 2)
YELLOW=$(tput -Txterm setaf 3)
WHITE=$(tput -Txterm setaf 7)
CYAN=$(tput -Txterm setaf 6)
RESET=$(tput -Txterm sgr0)

# Startup message
echo $CYAN"    _____                            "
echo $CYAN"   /     \\                           "
echo $CYAN"   vvvvvvv  /|__/|                   "
echo $CYAN"      I   /O,O   |                   "
echo $CYAN"      I /_____   |  "$YELLOW"    /|/|         "
echo $CYAN"     J|/^ ^ ^ \\  | "$YELLOW"   /00  |  "$GREEN"  _//| "
echo $CYAN"      |^ ^ ^ ^ |W|  "$YELLOW" |/^^\\ |  "$GREEN" /oo | "
echo $CYAN"       \\m___m__|_| "$YELLOW"   \\m_m_| "$GREEN"  \\mm_| "

# Set default user
DEFAULT_USER='hiroya.gojo'

# Allows hyphen-insensitive completion. (- and _ is interchangeable)
HYPHEN_INSENSITIVE="true"

# Enables command auto-correction.
ENABLE_CORRECTION="true"

# Shows dots while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Use vim as default editor
VISUAL=/usr/bin/vim

# Vi mode plugin options
VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
VI_MODE_SET_CURSOR=true

# PATHS
export GOPATH=$HOME/go
export PATH=$PATH:~/.dotnet/tools:$GOPATH/bin
export PATH=/usr/local/opt/ruby/bin:$PATH

# Vim mode editing in zsh
bindkey -v

# oh-my-zsh
ZSH_THEME="aussiegeek"
ZSH_DISABLE_COMPFIX=true
ZSH="/Users/hiroya.gojo/.oh-my-zsh"
plugins=(zsh-autosuggestions vi-mode colored-man-pages)
# plugins=(git web-search zsh-autosuggestions kubectl gcloud lol colored-man-pages docker aws battery vi-mode)
source $ZSH/oh-my-zsh.sh

# Hidden functions (doesn't need to be explicit)
# HIDE: Shorter git
alias g="git"
# HIDE: Shorter kubectl
alias k="kubectl"
# HIDE: Smarter mkdir
alias mkdir="mkdir -p"

# Obsidian dir
export OBSIDIAN_PATH=/Users/hiroya.gojo/Library/Mobile\ Documents/iCloud~md~obsidian/Documents

# DIRECTORIES
export PERSONAL_DIR=$HOME/PersonalCode
export CREDS_DIR=$HOME/Documents/credentials
export SCRIPTS_DIR=$PERSONAL_DIR/scripts
export LINUX_DIR=$SCRIPTS_DIR/ubuntu-sandbox

# Create new commit and push with message
function quickgit()
{
	git add --all
	git commit -m $1
	git push
}

# Create new commit with current branch name and push. Optional message append
function newcommit()
{
	MESSAGE=""
	while getopts "fm:" flag; do
		case "${flag}" in
			f) GITFLAGS=-f ;;
			m) MESSAGE=${OPTARG} ;;
		esac
	done

	git add --all

	if [[ $MESSAGE != "" ]]; then
		git commit -m $(git branch --show-current)-$MESSAGE > /dev/null
	else
		git commit -m $(git branch --show-current) > /dev/null
	fi

	git push ${GITFLAGS} > /dev/null || \
		git push ${GITFLAGS} --set-upstream origin $(git branch --show-current) > /dev/null
}

# Create new branch. Usage: newbranch branch-name base-branch=master
function newbranch()
{
	if [[ $2 ]]; then
		git checkout $2
	else
		git checkout master
	fi

	git pull
	git checkout -b $1
}

# Delete merged branches
alias delmerged='git branch --merged | egrep -v "(^\*|master|main|dev)" | xargs git branch -d'

# Install new finsync
function installfinsync()
{
	FINPATH=~/Documents/finance-project
	FINSRCPATH=~/PersonalCode/finance
	IS_INSIDE=$(insidedir $FINSRCPATH)

	if [[ ! $IS_INSIDE ]] pushd $FINSRCPATH > /dev/null
	dotnet build
	rm -rf $FINPATH/bin
	cp -r $FINSRCPATH/FinancePipeline/bin/Debug/net5.0 $FINPATH/bin
	cp $FINSRCPATH/graph-script/graph.py $FINPATH/graph.py
	if [[ ! $IS_INSIDE ]] popd > /dev/null
}

# Sync mint with google sheets
function finsync()
{
	FINPATH=~/Documents/finance-project
	CREDPATH=~/Documents/credentials/finance-pipeline
	SPREADSHEET="1pNs9XrzAQsuizWVbvq4D5yDQ4nESZpw--V7kI6tT91E"

	IS_INSIDE=$(insidedir $FINPATH)
	if [[ ! $IS_INSIDE ]] pushd $FINPATH > /dev/null

	# And, no the spreadsheet-id is not a secret/key. Nice try
	dotnet $FINPATH/bin/FinancePipeline.dll \
		hiroyagojo@gmail.com $MINT_PASS \
		--google-cred-path "$CREDPATH/finance-pipeline-325808-36b341a22811.json" \
		--filter-path "$FINPATH/filter.csv" \
		--spreadsheet-id $SPREADSHEET \
		--driver-path "$FINPATH" \
		--category-path "$FINPATH/category-file.json" \
		--mfa-secret $MFA_SECRET \
		--transactions-path "$FINPATH/transactions.csv"
	python3 $FINPATH/graph.py $FINPATH/transactions.csv
	open -a "Google Chrome" https://docs.google.com/spreadsheets/d/${SPREADSHEET}

	if [[ ! $IS_INSIDE ]] popd > /dev/null
}

# Display all extensions in folder (use -r for recursive, -a for hidden, -d for custom directory)
function extc()
{
	LS_FLAGS=''
	DIR_PATH=$(pwd)
	while getopts "ard:" flag; do
		case "${flag}" in
			r) LS_FLAGS=${LS_FLAGS}R ;;
			a) LS_FLAGS=${LS_FLAGS}a ;;
			d) dirpath=${OPTARG} ;;
		esac
	done

	ls -p${LS_FLAGS} $DIR_PATH | grep -v / | grep -v -e '^$' | perl -ne 'print lc' | awk -F . '{print $NF}' | sort | uniq -c | sort
}

# Performs brew maintenance
function brewing()
{
	# Mac Apps
	# sudo softwareupdate -i -a

	# Ruby
	gem update

	# Brew
	brew update
	brew upgrade
	brew cleanup
	brew leaves > $SCRIPTS_DIR/cattle/brew.txt

	# Node js
	npm update -g
	ls $(npm root -g) > $SCRIPTS_DIR/cattle/npm.txt

	# Python
	pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install -U
	pip3 freeze > $SCRIPTS_DIR/cattle/pip.txt

	# Save to cattle
	IS_INSIDE=$(insidedir $SCRIPTS_DIR)
	if [[ ! $IS_INSIDE ]] pushd $SCRIPTS_DIR > /dev/null
	git add cattle/brew.txt cattle/npm.txt cattle/pip.txt && \
		git commit -m "Add packages" && \
		git push
	if [[ ! $IS_INSIDE ]] popd > /dev/null
}

# Reload zshrc file
alias rezsh='source ~/.zshrc'

# Display all commands
alias cmds='DOTFILE_DIR=$PERSONAL_DIR/dotfiles; $SCRIPTS_DIR/cmds/cmds.rb $DOTFILE_DIR/zwork.zshrc $DOTFILE_DIR/zpersonal.zshrc $DOTFILE_DIR/zsecret.zshrc'

# Install vim vundle plugins
alias vimplugin='vim +PluginInstall +qall'

# Edit zshrc files
alias zshedit='code $PERSONAL_DIR/dotfiles -g $PERSONAL_DIR/dotfiles/zpersonal.zshrc'

# HIDE: Function to check if inside a directory
function insidedir() { [[ $(pwd) == $1 ]] }

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

# Open python playground
function pyplay()
{
	PORTS=$(jupyter notebook list --jsonlist | jq '.[].port')
	if [[ $PORTS != *"8889"* ]]; then
		nohup jupyter notebook --notebook-dir=$SCRIPTS_DIR/notebook --port 8889 --no-browser >/dev/null 2>&1 &
		sleep 1
	fi

	open -a "Google Chrome" http://localhost:8889/notebooks/play.ipynb
}

# Backup secrets to google drive
function sbackup()
{
	FILENAME=/tmp/$(date +%s).tar

	# Create zip
	sudo tar cfvz ${FILENAME} \
		$HOME/PersonalCode/dotfiles/*.zshrc \
		$HOME/Documents/credentials \
		$HOME/.kube/homeconfig \
		$HOME/.config/rclone \
		$HOME/.ssh \
		$HOME/.aws

	# Move into drive
	sudo rclone copy $FILENAME MainDrive:/Backup
	echo "Finished backing up $FILENAME"
	sudo rm $FILENAME

	# Remove old backups
	EXISTING_FILES=$(rclone ls MainDrive:Backup | awk '{print $2}')
	echo $EXISTING_FILES | while read -r f; do
		PAST_DATE=$(echo $f | sed 's/\.tar//g')
		CURRENT_DATE=$(date +%s)

		DIFF=$(expr $CURRENT_DATE - $PAST_DATE)
		DIFF_IN_DAYS=$(expr $DIFF / 60 / 60 / 24)

		if [[ $DIFF_IN_DAYS > 21 ]]; then
			echo "Deleting file $f"
			rclone delete MainDrive:Backup/$f
		fi
	done
}

# Convert HEIC formatted photos to jpeg in a folder
function heic2jpg()
{
	WORK_DIR=$(pwd)
	if [[ $1 ]]; then
		WORK_DIR=$1
	fi

	for i in $WORK_DIR/*.HEIC; do
		sips -s format jpeg "$i" --out "$i.jpg"
	done

	for i in $WORK_DIR/*.heic; do
		sips -s format jpeg "$i" --out "$i.jpg"
	done
}

# Unzip all .zip files in a directory in a flat structure
function unzipall()
{
	WORK_DIR=$(pwd)
	if [[ $1 ]]; then
		WORK_DIR=$1
	fi

	for i in *.zip; do
		unzip -j $i
	done
}