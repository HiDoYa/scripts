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
export PATH=$HOMEBREW_PREFIX/opt/ruby/bin:$PATH

# Change location of zcompdump file
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

# Vim mode editing in zsh
bindkey -v

# Required to use vault lookup in ansible
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# oh-my-zsh
ZSH_THEME="aussiegeek"
ZSH_DISABLE_COMPFIX=true
ZSH=$HOME/.oh-my-zsh
plugins=(vi-mode colored-man-pages)
source $ZSH/oh-my-zsh.sh
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh

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
export OBSIDIAN_DIR=$HOME/Library/Mobile\ Documents/iCloud~md~obsidian/Documents

# Draw.io cli
alias drawio='/Applications/draw.io.app/Contents/MacOS/draw.io'

# Reload zshrc file
alias rezsh='source ~/.zshrc'

# Display all commands
alias cmds='$SCRIPTS_DIR/cmds/cmds.rb ~/.zshrc'

# Install vim vundle plugins
alias vimplugin='vim +PluginInstall +qall'

# Edit zshrc files
alias zshedit='code $SCRIPTS_DIR -g $SCRIPTS_DIR/dotfiles/zshrc/00-general.zshrc'

# HIDE: Function to check if inside a directory
function insidedir() { [[ $(pwd) == $1 ]] }

# Performs brew maintenance
function brewing()
{
	# Ruby
	gem update

	# Brew
	brew update
	brew upgrade
	brew outdated
	brew cleanup

	# Node js
	npm update -g

	# Python
	pip3 list --outdated --format=json | jq -r '.[] | "\(.name)==\(.latest_version)"' | xargs -n1 pip3 install -U
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
