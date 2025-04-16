# TITLE: Fileops

# HIDE: Function to check if inside a directory
function insidedir() { [[ $(pwd) == $1 ]] }

# Edit zshrc files
alias zshedit='code $SCRIPTS_DIR -g $SCRIPTS_DIR/dotfiles/zshrc/05-general.zshrc'

# Reload zshrc file
alias rezsh='source ~/.zshrc'

# Tmux save buffer
alias tmux-save-all='tmux capture-pane -pS -'

# Tmux save buffer since last prompt
function tmux-save() {
	# Number of commands to capture
	# Lookback + 1 since we want to ignore our current command itself
	LOOKBACK=$((1+${1:-1}))

	BUFFER=$(tmux capture-pane -pS -)
	LNOS=$(echo $BUFFER | grep -ne '^hiroya\.gojo.*' | tail -${LOOKBACK} | cut -d":" -f1)
	FRST=$(echo $LNOS | head -n 1)
	LAST=$(($(echo $LNOS | tail -n 1) - 1))
	echo $BUFFER | sed -n "${FRST},${LAST}p"
}

# Display all commands
function cmds() {
	pushd $SCRIPTS_DIR/cmds > /dev/null
	bundle exec ruby $SCRIPTS_DIR/cmds/cmds.rb -f ~/.zshrc
	popd > /dev/null
}

# Display all commands
function cmds-info() {
	pushd $SCRIPTS_DIR/cmds > /dev/null
	bundle exec ruby $SCRIPTS_DIR/cmds/cmds.rb -f ~/.zshrc -m INFO
	popd > /dev/null
}

# Point calculator (-s 12/12/23 -p 10)
function pointcalc() {
	pushd $SCRIPTS_DIR/pointcalc > /dev/null
	bundle exec ruby $SCRIPTS_DIR/pointcalc/pointcalc.rb -f $SCRIPTS_DIR/pointcalc/holidays.yaml $@
	popd> /dev/null
}

# Brew casks/formula backup
function bayleaf() {
	pushd $SCRIPTS_DIR/bayleaf > /dev/null
	bundle exec ruby $SCRIPTS_DIR/bayleaf/bayleaf.rb
	popd> /dev/null
}

# Install vim vundle plugins
alias vimplugin='vim +PluginInstall +qall'

# Performs brew maintenance
function brewing() {
	# Brew
	brew update
	brew upgrade
	brew outdated
	brew cleanup

	# Node js
	npm update -g

	# Ruby
	# Commented out to figure out ruby environment first
	# gem update

	# Python
	# Deprecated: No longer install packages globally
	# pip3 list --outdated --format=json | jq -r '.[] | "\(.name)==\(.latest_version)"' | xargs -n1 pip3 install -U
}

# Unzip all .zip files in a directory in a flat structure
function unzipall() {
	WORK_DIR=$(pwd)
	if [[ $1 ]]; then
		WORK_DIR=$1
	fi

	for i in *.zip; do
		unzip -j $i
	done
}

# Create and activate new python venv
function newpyvenv() {
	python3 -m venv .venv
	source .venv/bin/activate
}

# Get my public ip
alias mypublicip="curl ident.me"

# Get my home local ip(s)
alias homelocalip="ifconfig | grep 172.18 | awk '{\$1=\$1};1'"
