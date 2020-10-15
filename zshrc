ZSH_DISABLE_COMPFIX=true

# Startup message
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
DEFAULT_USER='hiroyagojo'

## ALIASES
# Basic
alias ll="ls -al"
alias la="ls -a"
alias mkdir="mkdir -p"
alias up="cd .."
function extc()
{
	recursive=false
	while getopts "r" flag; do
		case "${flag}" in
			r) recursive=true
		esac
	done

	if ${recursive}; then
		ls -pR | grep -v / | grep -v -e '^$' | awk -F . '{print $NF}' | sort | uniq -c | sort
	else
		ls -p | grep -v / | grep -v -e '^$' | awk -F . '{print $NF}' | sort | uniq -c | sort
	fi
}
function quickgit()
{
	git add --all
	git commit -m $1
	git push
}

# Use vim as default editor
export VISUAL=/usr/bin/vim

# Path to oh-my-zsh installation
export ZSH=/Users/hiroyagojo/.oh-my-zsh

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

# Path
export PATH=$PATH:/usr/local/bin

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/hiroyagojo/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/hiroyagojo/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/hiroyagojo/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/hiroyagojo/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

# Vim mode editing in zsh
bindkey -v
