#!/bin/zsh

dotfiles=("zshrc" "vimrc" "tmux.conf" "gitconfig" "gitignore")
repos_path=${0:A:h}

function install {
	for file in $dotfiles; do
		echo Installing ~/.$file
		cp $repos_path/$file ~/.$file
	done
}

function save {
	for file in $dotfiles; do
		echo Saving ~/.$file to repo
		cp ~/.$file $repos_path/$file
	done
}

if [ $# = 1 ]; then
	if [ $1 = "install" ]; then
		install
		exit
	fi
	if [ $1 = "save" ]; then
		save
		exit
	fi
fi

echo "Usage: ./dotfiles.sh install|save"
