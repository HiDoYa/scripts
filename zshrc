# Startup message
echo "    _____                            "
echo "   /     \\                           "
echo "   vvvvvvv  /|__/|                   "
echo "      I   /O,O   |                   "
echo "      I /_____   |      /|/|         "
echo "     J|/^ ^ ^ \\  |    /00  |    _//| "
echo "      |^ ^ ^ ^ |W|   |/^^\\ |   /oo | "
echo "       \\m___m__|_|    \\m_m_|   \\mm_| "

ZSH_DISABLE_COMPFIX=true
ZSH_THEME="agnoster"

# So the user@hostname doesn't show
DEFAULT_USER='hiroyagojo'

## ALIASES
alias joinpdf="/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py"
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

# Allows hyphen-insensitive completion. (- and _ is interchangeable)
HYPHEN_INSENSITIVE="true"

# Enables command auto-correction.
ENABLE_CORRECTION="true"

# Shows dots while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Vi mode plugin options
VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
VI_MODE_SET_CURSOR=true

# Plugins
export ZSH=/Users/hiroyagojo/.oh-my-zsh
plugins=(git web-search zsh-autosuggestions kubectl gcloud lol colored-man-pages docker aws battery vi-mode)
source $ZSH/oh-my-zsh.sh

# PATHS
PATH=/usr/local/bin:$PATH

# Vim mode editing in zsh
bindkey -v

# Add kubernetes cluster prompt
source /usr/local/Cellar/kube-ps1/0.7.0/share/kube-ps1.sh
RPROMPT='$(kube_ps1)'$RPROMPT

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/hiroyagojo/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/hiroyagojo/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/hiroyagojo/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/hiroyagojo/google-cloud-sdk/completion.zsh.inc'; fi

export CLOUDSDK_PYTHON="/usr/bin/python3"

# Visual studio code
export PATH=$PATH:"/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

