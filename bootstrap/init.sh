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

# Install tools (any tools specified in zshrc files)
brew install bat dog duf exa fd git-delta \
    htop jq jupyterlab kubectl ncdu node \
    npm pgcli procs rclone rg ruby vagrant

# Install tools (recommended)
brew install docker-compose go httpie hugo \
    netcat newman nmap packer parallel pwgen \
    ripgrep terraform tree vault wget yq

# Install gui tools (recommended)
brew install --cask 1password copyclip \
    discord discretescroll docker drawio \
    gimp google-chrome iterm2 obs obsidian \
    postman spotify vagrant visual-studio-code \
    vmware-fusion

# Install dotfiles
pushd ../dotfiles
./install.py home
rezsh
popd

# Install vundle plugins
vim +PluginInstall +qall

# Ensure vimbackup dir exists
mkdir -p ~/.vimbackup

# Define Colors
GREEN='\033[0;32m'
NC='\033[0m'

# VSCode
echo "${GREEN}VScode installed"
echo "Install CLI using: Command Palette -> shell"
echo ""

# Iterm
echo "${GREEN}Iterm installed"
echo "Update options using: Settings -> General -> Preferences -> Load preferences from a folder"
echo ""