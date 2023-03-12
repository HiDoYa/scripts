# Scripts

Scripts, files, and other misc files for personal use. Many of these interact with shell scripts I wrote in zshrc.

## Metadata Extractor
This is a specialized script (that'll probably only ever be used once).

I first got a list of all my songs by running '''ls -alR''' on my local music library, using directory structure to denote playlist name.

Then, I ran the following parse.sh script to separate out the title and authors of the songs and sort them according to the occurence under playlist buckets.

## Cmd List
Script to list all bash/zsh functions and aliases in a smart way.

## Cattle
Files for keeping track of software packages for easy installation.

## Google Photos Backup
Set of scripts to help automate backing up media from my phone and compress it. 

gp\_download.py downloads all media from Google Photos. (Note: deleting of media must be done manually, can't be done with the API).

vid\_c.sh compresses all video files (-i for input, -o for output).

## Notebook
Filespace for Jupyter notebook workspace.

## Smart Mv
Move many files to a destination, but if the same filename already exists, create a new filename so that it isn't overwritten.

## Linux Dev Sandbox
Files related to running Ubuntu workspace with Vagrant.

## Dotfiles

Repository for saving dotfiles for git, tmux, vim, zsh.

Many of the files here are not checked into Git since they are private. When migrating to a new system, be sure to copy the entire old directory.

### Usage
WARNING: This script will wipe use dotfiles. 

Run ./install.py to configure the zshrc, vimrc, and gitconfig
