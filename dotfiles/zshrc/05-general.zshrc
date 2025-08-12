# Brew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Define colors
export RESET=$(tput -Txterm sgr0)
export BLACK=$(tput -Txterm setaf 0)
export RED=$(tput -Txterm setaf 1)
export GREEN=$(tput -Txterm setaf 2)
export YELLOW=$(tput -Txterm setaf 3)
export BLUE=$(tput -Txterm setaf 4)
export MAGENTA=$(tput -Txterm setaf 5)
export CYAN=$(tput -Txterm setaf 6)
export WHITE=$(tput -Txterm setaf 7)
export BOLD=$(tput -Txterm bold)
export BG_RED=$(tput -Txterm setab 1)
export BG_GREEN=$(tput -Txterm setab 2)
export BG_YELLOW=$(tput -Txterm setab 3)

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
export HYPHEN_INSENSITIVE="true"

# Enables command auto-correction.
export ENABLE_CORRECTION="true"

# Shows dots while waiting for completion
export COMPLETION_WAITING_DOTS="true"

# Use vim as default editor
export VISUAL=/usr/bin/vim
export EDITOR=vim

# Python settings
export PIP_REQUIRE_VIRTUALENV=true
# Pipx binaries
export PATH=/Users/hiroya.gojo/.local/bin:$PATH

# Go settings
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# Initialize completions with ZSH's compinit
autoload -Uz compinit && compinit

# Asdf shims
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
# Asdf auto-complete
# Append completions to fpath
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)

# Jujutsu autocompletions
source <(jj util completion zsh)

# Change location of zcompdump file
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

# Required to use vault lookup in ansible
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# Oh My Zsh
export ZSH_THEME="steeef"
export ZSH_DISABLE_COMPFIX=true
export ZSH=$HOME/.oh-my-zsh
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-${ZSH_VERSION}
plugins=(colored-man-pages)
source $ZSH/oh-my-zsh.sh
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Disable auto correct because it can be annoying
unsetopt correct_all

# Fzf key bindings
eval "$(fzf --zsh)"

# Command history
export HISTFILE=~/.zsh_history
export HISTSIZE=999999999
export SAVEHIST=$HISTSIZE

# Atuin for command history
eval "$(atuin init zsh --disable-up-arrow)"
bindkey '^r' atuin-search

# HIDE: Alacritty not recognized by most devices
alias ssh='TERM=xterm-256color ssh'

# Directories
export CODE_DIR=$HOME/Code
export SCRIPTS_DIR=$CODE_DIR/scripts

# Alt arrow/h/l to move between arrows
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^[l" forward-word
bindkey "^[h" backward-word
