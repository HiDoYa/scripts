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

# Go binaries
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# Ruby binaries
export PATH=/usr/local/opt/ruby/bin:$PATH

# Change location of zcompdump file
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

# Vim mode editing in zsh
bindkey -v

# Required to use vault lookup in ansible
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# oh-my-zsh
ZSH_THEME="aussiegeek"
ZSH_DISABLE_COMPFIX=true
ZSH=/Users/$USER/.oh-my-zsh
plugins=(zsh-autosuggestions zsh-syntax-highlighting vi-mode colored-man-pages)
# plugins=(git gcloud lol docker aws)
source $ZSH/oh-my-zsh.sh

# Hidden functions (doesn't need to be explicit)
# HIDE: Shorter git
alias g="git"
# HIDE: Shorter kubectl
alias k="kubectl"
# HIDE: Smarter mkdir
alias mkdir="mkdir -p"
# HIDE: bat is modern cat
alias cat="bat"
# HIDE: duf is modern df
alias df="duf"
# HIDE: delta is modern diff
alias diff="delta"
# HIDE: dog is modern dig
alias dig="dog"
# HIDE: ncdu is modern du
alias du="ncdu"
# HIDE: fd is modern find
alias find="fd"
# HIDE: ripgrep is modern grep
alias grep="rg"
# HIDE: exa is modern ls
alias ls="exa"
# HIDE: procs is modern ps
alias ps="procs"
# HIDE: pgcli is modern psql
alias psql="pgcli"
# HIDE: htop is modern top
alias top="htop"

# DIRECTORIES
export CODE_DIR=$HOME/Code
export CREDS_DIR=$HOME/Documents/credentials
export SCRIPTS_DIR=$CODE_DIR/scripts
export LINUX_DIR=$SCRIPTS_DIR/linux-dev
export OBSIDIAN_PATH=/Users/$USER/Library/Mobile\ Documents/iCloud~md~obsidian/Documents

# Draw.io cli
alias drawio=/Applications/draw.io.app/Contents/MacOS/draw.io

# Reload zshrc file
alias rezsh='source ~/.zshrc'

# Display all commands
alias cmds='$SCRIPTS_DIR/cmds/cmds.rb ~/.zshrc'

# Install vim vundle plugins
alias vimplugin='vim +PluginInstall +qall'

# Edit zshrc files
alias zshedit='code $SCRIPTS_DIR/dotfiles -g $SCRIPTS_DIR/dotfiles/zshrc/general.zshrc'

# HIDE: Function to check if inside a directory
function insidedir() { [[ $(pwd) == $1 ]] }

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

	# Node js
	npm update -g

	# Python
	pip3 list --outdated --format=json | jq -r '.[] | "\(.name)==\(.latest_version)"' | xargs -n1 pip3 install -U

	# TODO Push to rclone instead as backups
	# # Save to files
	# gem list
	# brew leaves > $SCRIPTS_DIR/cattle/brew.txt
	# ls $(npm root -g) > $SCRIPTS_DIR/cattle/npm.txt
	# pip3 freeze > $SCRIPTS_DIR/cattle/pip.txt

	# # Save to cattle
	# IS_INSIDE=$(insidedir $SCRIPTS_DIR)
	# if [[ ! $IS_INSIDE ]] pushd $SCRIPTS_DIR > /dev/null
	# 	git add cattle/brew.txt cattle/npm.txt cattle/pip.txt && \
	# 	git commit -m "Add packages" && \
	# 	git push
	# if [[ ! $IS_INSIDE ]] popd > /dev/null
}

# Open python playground in jupyter notebook
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
		$CODE_DIR/dotfiles/*.zshrc \
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
