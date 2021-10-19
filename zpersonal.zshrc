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
	message=""
	while getopts "fm:" flag; do
		case "${flag}" in
			f) gitflags=-f ;;
			m) message=${OPTARG} ;;
		esac
	done

	git add --all

	if [[ $message != "" ]]; then
		git commit -m $(git branch --show-current)-$message > /dev/null
	else
		git commit -m $(git branch --show-current) > /dev/null
	fi

	git push ${gitflags} > /dev/null || git push ${gitflags} --set-upstream origin $(git branch --show-current) > /dev/null

	# Not necessary
	# mr_id=$(lab mr list $(git branch --show-current) | sed 's/!//g' | awk '{print $1}') && lab mr show $mr_id | tail -n 1
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

# Sync mint with google sheets
function finsync
{
	finpath=~/Documents/personal/finance-project
	spreadsheet="1pNs9XrzAQsuizWVbvq4D5yDQ4nESZpw--V7kI6tT91E"
	# And, no the spreadsheet-id is not a secret/key. Nice try
	dotnet $finpath/bin/FinancePipeline.dll \
		hiroyagojo@gmail.com $MINT_PASS \
		--google-cred-path "~/Documents/credentials/finance-pipeline/finance-pipeline-325808-36b341a22811.json" \
		--filter-path "$finpath/filter.csv" \
		--spreadsheet-id $spreadsheet \
		--category-path "$finpath/category-file.json"
	open -a "Google Chrome" https://docs.google.com/spreadsheets/d/${spreadsheet}
}

# Display all extensions in folder (use -r for recursive, -a for hidden, -d for custom directory)
function extc()
{
	lsflags=''
	dirpath=$(pwd)
	while getopts "ard:" flag; do
		case "${flag}" in
			r) lsflags=${lsflags}R ;;
			a) lsflags=${lsflags}a ;;
			d) dirpath=${OPTARG} ;;
		esac
	done

	ls -p${lsflags} $dirpath | grep -v / | grep -v -e '^$' | perl -ne 'print lc' | awk -F . '{print $NF}' | sort | uniq -c | sort
}

# Performs brew maintenance
function brewing()
{
	SCRIPTS_PATH=~/PersonalCode/scripts

	brew update
	brew upgrade
	brew cleanup
	brew leaves > $SCRIPTS_PATH/cattle/brew.txt

	IS_INSIDE=$(insidedir $SCRIPTS_PATH)
	if [[ ! $IS_INSIDE ]] pushd $SCRIPTS_PATH > /dev/null
	git add cattle/brew.txt && git commit -m "Add brew packages" && git push
	if [[ ! $IS_INSIDE ]] popd > /dev/null
}

# Reload zshrc file
alias rezsh='source ~/.zshrc'

export PERSONAL_DIR=$HOME/PersonalCode

# Display all commands
alias cmds='dot_dir=$PERSONAL_DIR/dotfiles; $PERSONAL_DIR/scripts/cmds.rb $dot_dir/zwork.zshrc $dot_dir/zpersonal.zshrc $dot_dir/zsecret.zshrc'

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

	VAGRANT_PATH=$PERSONAL_DIR/scripts/ubuntu-sandbox
	IS_INSIDE=$(insidedir $VAGRANT_PATH)

	if [[ ! $IS_INSIDE ]] pushd $VAGRANT_PATH > /dev/null

	# Is this necessary?
	# STATUS=$(vagrant status linux-dev --machine-readable | awk -F ',' '{ if ($3 == "state") {print $4} }')

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
	VAGRANT_PATH=$PERSONAL_DIR/scripts/ubuntu-sandbox
	IS_INSIDE=$(insidedir $VAGRANT_PATH)

	if [[ ! $IS_INSIDE ]] pushd $VAGRANT_PATH > /dev/null
	vagrant status linux-dev 
	if [[ ! $IS_INSIDE ]] popd > /dev/null
}

# SSH into linux dev
function linuxssh()
{
	VAGRANT_PATH=$PERSONAL_DIR/scripts/ubuntu-sandbox
	IS_INSIDE=$(insidedir $VAGRANT_PATH)

	if [[ ! $IS_INSIDE ]] pushd $VAGRANT_PATH > /dev/null
	vagrant ssh linux-dev 
	if [[ ! $IS_INSIDE ]] popd > /dev/null
}

# Clean up and destroy linux dev
function linuxdown()
{
	VAGRANT_PATH=$PERSONAL_DIR/scripts/ubuntu-sandbox
	IS_INSIDE=$(insidedir $VAGRANT_PATH)

	if [[ ! $IS_INSIDE ]] pushd $VAGRANT_PATH > /dev/null
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

	VAGRANT_PATH=$PERSONAL_DIR/scripts/ubuntu-sandbox
	IS_INSIDE=$(insidedir $VAGRANT_PATH)

	ABS_PATH=$(realpath $1)
	if [[ ! $IS_INSIDE ]] pushd $VAGRANT_PATH > /dev/null
	vagrant scp linux-dev:.
	if [[ ! $IS_INSIDE ]] popd > /dev/null
}

# Get status of linux dev
function linuxst()
{
	VAGRANT_PATH=$PERSONAL_DIR/scripts/ubuntu-sandbox
	IS_INSIDE=$(insidedir $VAGRANT_PATH)

	if [[ ! $IS_INSIDE ]] pushd $VAGRANT_PATH > /dev/null
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
		nohup jupyter notebook --notebook-dir=$PERSONAL_DIR/scripts/notebook --port 8889 --no-browser >/dev/null 2>&1 &
		sleep 1
	fi

	open -a "Google Chrome" http://localhost:8889/notebooks/play.ipynb
}

# Backup secrets to google drive
function sbackup()
{
	filename=/tmp/$(date +%s).tar
	rclone=/usr/local/bin/rclone

	# Create zip
	tar cfvz ${filename} \
		$HOME/PersonalCode/dotfiles/*.zshrc \
		$HOME/Documents/credentials \
		$HOME/.kube/homeconfig \
		$HOME/.config/rclone \
		$HOME/.ssh \
		$HOME/.aws

	# Move into drive
	$rclone copy $filename Drive:/Backup
	rm $filename

	# Remove old backups
	existing_files=$($rclone ls Drive:Backup | awk '{print $2}')
	for f in $existing_files; do
		past_date=$(echo $f | sed 's/\.tar//g')
		current_date=$(date +%s)

		diff=$(expr $current_date - $past_date)
		diff_in_days=$(expr $diff / 60 / 60 / 24)

		if [[ $diff_in_days > 21 ]]; then
			$rclone delete Drive:Backup/$f
		fi
	done
}