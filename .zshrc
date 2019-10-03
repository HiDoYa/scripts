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
DEFAULT_USER='hidoya'

## ALIASES
# Basic
alias ll="ls -al"
alias la="ls -a"
alias mkdir="mkdir -p"
alias vscodecpu="code --folder-uri sftp://cpu/"
alias csif="ssh higojo@pc11.cs.ucdavis.edu"
function quickgit()
{
	git add --all
	git commit -m $1
	git push
}

## LINUX CONFIGS
# # Goes to my "zet" drive using $
# zet="/media/hidoya/Zet/Users/Hiroya"
# # For storing dotfiles in git
# alias config='/usr/bin/git --git-dir=/home/hidoya/.cfg/ --work-tree=/home/hidoya'
# # For starting apache2
# alias apacheStart="sudo /usr/local/apache2/bin/apachectl start"
# alias apacheStop="sudo /usr/local/apache2/bin/apachectl stop"
# alias apacheLoc="cd /usr/local/apache2/"
# 
# # For linuxbrew
# export PATH="/home/hidoya/.linuxbrew/bin:$PATH"
# export MANPATH="/home/hidoya/.linuxbrew/share/man:$MANPATH"
# export INFOPATH="/home/hidoya/.linuxbrew/share/info:$INFOPATH"
# 
# # Use vim as default editor
# export EDITOR=/usr/bin/vim
# export VISUAL=/usr/bin/vim

# Path to oh-my-zsh installation
export ZSH=/Users/hidoya/.oh-my-zsh

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
if [ -f '/Users/hidoya/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/hidoya/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/hidoya/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/hidoya/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
