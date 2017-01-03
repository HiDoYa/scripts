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
# For storing dotfiles in git
alias config='/usr/bin/git --git-dir=/home/hidoya/.cfg/ --work-tree=/home/hidoya'

# Use vim as default editor
export EDITOR=/usr/bin/vim
export VISUAL=/usr/bin/vim

# Path to oh-my-zsh installation
export ZSH=/home/hidoya/.oh-my-zsh

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Plugins
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(git web-search)
source $ZSH/oh-my-zsh.sh

