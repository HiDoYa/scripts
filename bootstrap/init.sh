#!/bin/zsh

# Ignore failure code
xcode-select --install || true

# Ensure brew is installed
if ! command -v brew &> /dev/null
then
    echo "Installing brew before continuing"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' > ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install zsh tools
brew install zsh-autosuggestions zsh-syntax-highlighting

# Install oh-my-zsh
if [ ! -d "~/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    source ~/.oh-my-zsh/oh-my-zsh.sh
fi

# Install vundle
if [ ! -d "~/.vim/bundle/Vundle.vim" ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

# Install app store apps
brew install mas
mas install 937984704 # Amphetamine
mas install 595191960 # Copyclip
mas install 288545208 # Instapaper
mas install 1295203466 # RDP
mas install 1475387142 # Tailscale client

# Install tools (any tools specified in zshrc files)
brew install atuin bat doggo duf eza fd \
    git-delta ncdu htop jq jupyterlab kubectl node \
    npm pgcli procs rclone rg ruby vagrant tmux

# Install tools (recommended)
brew install docker-compose go httpie hugo \
    netcat newman nmap packer parallel pwgen \
    ripgrep terraform tree vault wget yq fclones \
    jnv bruno

# Install gui tools
brew install --cask 
    1password \
    alacritty \
    basictex \
    deluge \
    discord \
    discretescroll \
    docker \
    drawio \
    freecad \
    gimp \
    godot \
    google-chrome \
    monitorcontrol \
    mono-sdk \
    ngrok \
    obs \
    obsidian \
    postman \
    spotify \
    the-unarchiver \
    vagrant \
    visual-studio-code \
    vlc \
    vmware-fusion

# Install dotfiles
echo ""
pushd ../dotfiles
./install.py home
popd

# Install vundle plugins
vim +PluginInstall +qall

# Ensure vimbackup dir exists
mkdir -p ~/.vimbackup

# Define Colors
GREEN='\033[0;32m'
NC='\033[0m'

# VSCode
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
echo ""
echo "${GREEN}VScode installed"
echo "Install CLI using: Command Palette -> shell"
echo ""

# Tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
./.tmux/plugins/tpm/scripts/install_plugins.sh

# Alacritty font
echo "Install DroidSansM Nerd Font"