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
export HYPHEN_INSENSITIVE="true"

# Enables command auto-correction.
export ENABLE_CORRECTION="true"

# Shows dots while waiting for completion
export COMPLETION_WAITING_DOTS="true"

# Use vim as default editor
export VISUAL=/usr/bin/vim
export EDITOR=vim

# Pipx
export PATH=$PATH:/Users/hiroya.gojo/.local/bin

# Go binaries
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# Ruby binaries
export PATH=$PATH:$HOMEBREW_PREFIX/opt/ruby/bin
export PATH=$PATH:$(gem environment home)/bin
export PATH=$PATH:$HOME/.rvm/bin

# Change location of zcompdump file
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

# Required to use vault lookup in ansible
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# oh-my-zsh
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

# HIDE: Alacritty not recognzied by most devices
alias ssh='TERM=xterm-256color ssh'

# DIRECTORIES
export CODE_DIR=$HOME/Code
export CREDS_DIR=$HOME/Documents/credentials
export SCRIPTS_DIR=$CODE_DIR/scripts
export OBSIDIAN_DIR=$HOME/Documents/Obsidian

# Alt arrow/h/l to move between arrows
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^[l" forward-word
bindkey "^[h" backward-word
