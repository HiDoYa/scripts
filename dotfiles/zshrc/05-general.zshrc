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
export PATH=/Users/$USER/.local/bin:$PATH

# Go settings
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# ZSH completions
# Initialize completions with ZSH's compinit
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
zmodload zsh/complist
# Completers (prioritize history)
zstyle ':completion:*' completer _extensions _complete _approximate
# Use cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zcompcache"
# Group matches
zstyle ':completion:*' group-name ''
# Group ordering
# zstyle ':completion:*:*:-command-:*:*' group-order alias builtins functions commands
# Select from a menu
zstyle ':completion:*' menu select
# Show menu on second Tab
setopt auto_menu
# Complete from cursor position
setopt complete_in_word
# Move cursor to end after completion
setopt always_to_end
# Show all file metadata (DOES NOT WORK WITH list-colors)
# zstyle ':completion:*' file-list all
# Squeeze /path//something/ to /path/something/
zstyle ':completion:*' squeeze-slashes true
# Color styling
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %D %d --%f'
zstyle ':completion:*:*:*:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:*:*:*:warnings' format ' %F{red}-- no matches found --%f'

# Mise shims
eval "$(mise activate zsh)"

# Change location of zcompdump file
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

# Required to use vault lookup in ansible
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# Autosuggestion config
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Oh My Zsh
export ZSH_THEME="steeef-jj"
export ZSH_DISABLE_COMPFIX=true
export ZSH=$HOME/.oh-my-zsh
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-${ZSH_VERSION}
plugins=(colored-man-pages)
source $ZSH/oh-my-zsh.sh

# Auto completions
source <(jj util completion zsh)
source <(tailscale completion zsh)
source <(docker completion zsh)
source <(kubectl completion zsh)
source <(helm completion zsh)
eval "$(op completion zsh)"; compdef _op op # 1password
complete -C '/usr/local/bin/aws_completer' aws

# zsh-vi-mode: Define keybindings after vi-mode loads
zvm_after_init() {
  # Atuin for command history
  eval "$(atuin init zsh --disable-up-arrow)"
  bindkey '^r' atuin-search
}
source $HOMEBREW_PREFIX/share/zsh-vi-mode/zsh-vi-mode.zsh
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Disable auto correct because it can be annoying
unsetopt correct_all

# Fzf key bindings
eval "$(fzf --zsh)"

# Command history
export HISTFILE=~/.zsh_history
export HISTSIZE=999999999
export SAVEHIST=$HISTSIZE

# HIDE: Alacritty not recognized by most devices
alias ssh='TERM=xterm-256color ssh'

# Directories
export CODE_DIR=$HOME/Code
export SCRIPTS_DIR=$CODE_DIR/scripts

# Cmd arrow/h/l to move between arrows
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^[l" forward-word
bindkey "^[h" backward-word
