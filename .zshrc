# Startup message
screenfetch
echo "    _____                            "
echo "   /     \\                           "
echo "   vvvvvvv  /|__/|                   "
echo "      I   /O,O   |                   "
echo "      I /_____   |      /|/|         "
echo "     J|/^ ^ ^ \\  |    /00  |    _//| "
echo "      |^ ^ ^ ^ |W|   |/^^\\ |   /oo | "
echo "       \\m___m__|_|    \\m_m_|   \\mm_| "

# Theme
ZSH_THEME="agnoster"

# So the user@hostname doesn't show
DEFAULT_USER='hidoya'

## ALIASES
# Basic
alias ll="ls -al"
alias la="ls -a"
alias mkdir="mkdir -p"
function quickgit()
{
	git add --all
	git commit -m $1
	git push
}
# For storing dotfiles in git
alias config='/usr/bin/git --git-dir=/home/hidoya/.cfg/ --work-tree=/home/hidoya'
# For starting apache2
alias apacheStart="sudo /usr/local/apache2/bin/apachectl start"
alias apacheStop="sudo /usr/local/apache2/bin/apachectl stop"
alias apacheLoc="cd /usr/local/apache2/"

# For linuxbrew
export PATH="/home/hidoya/.linuxbrew/bin:$PATH"
export MANPATH="/home/hidoya/.linuxbrew/share/man:$MANPATH"
export INFOPATH="/home/hidoya/.linuxbrew/share/info:$INFOPATH"

# Use vim as default editor
export EDITOR=/usr/bin/vim
export VISUAL=/usr/bin/vim

# Path to oh-my-zsh installation
export ZSH=/home/hidoya/.oh-my-zsh

# Allows hyphen-insensitive completion. (- and _ is interchangeable)
HYPHEN_INSENSITIVE="true"

# Enables command auto-correction.
ENABLE_CORRECTION="true"

# Shows dots while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Plugins
# ~/.oh-my-zsh/plugins
plugins=(git web-search)
source $ZSH/oh-my-zsh.sh

