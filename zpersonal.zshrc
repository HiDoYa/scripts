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

# Set default user
DEFAULT_USER='hiroya.gojo'

# Allows hyphen-insensitive completion. (- and _ is interchangeable)
HYPHEN_INSENSITIVE="true"

# Enables command auto-correction.
ENABLE_CORRECTION="true"

# Shows dots while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Use vim as default editor
VISUAL=/usr/bin/vim

# Vi mode plugin options
VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
VI_MODE_SET_CURSOR=true

# PATHS
export GOPATH=$HOME/go
export PATH=$PATH:~/.dotnet/tools:$GOPATH/bin
# Is this necessary?
# export PATH=$PATH:~/Library/Python/3.9/bin

# Vim mode editing in zsh
bindkey -v

# oh-my-zsh Theme
ZSH_THEME="aussiegeek"
ZSH_DISABLE_COMPFIX=true

# oh-my-zsh
ZSH="/Users/hiroya.gojo/.oh-my-zsh"
plugins=(zsh-autosuggestions vi-mode colored-man-pages)
# plugins=(git web-search zsh-autosuggestions kubectl gcloud lol colored-man-pages docker aws battery vi-mode)
source $ZSH/oh-my-zsh.sh

# Shorter git
alias g="git"

# Shorter kubectl
alias k="kubectl"

# Smarter mkdir
alias mkdir="mkdir -p"

# Create new commit and push with message
function quickgit()
{
	git add --all
	git commit -m $1
	git push
}

# Create new commit with current branch name and push. Optional message append
function newcommit()
{
	git add --all

	if [[ $1 ]]; then
		git commit -m $(git branch --show-current)-$1 > /dev/null
	else
		git commit -m $(git branch --show-current) > /dev/null
	fi

	git push > /dev/null || git push --set-upstream origin $(git branch --show-current) > /dev/null

	mr_id=$(lab mr list $(git branch --show-current) | sed 's/!//g' | awk '{print $1}') && lab mr show $mr_id | tail -n 1
}

# Create new branch. Usage: newbranch branch-name base-branch=master
function newbranch()
{
	if [[ $2 ]]; then
		git checkout $2
	else
		git checkout master
	fi

	git pull
	git checkout -b $1
}

# Delete merged branches
alias delmerged='git branch --merged | egrep -v "(^\*|master|main|dev)" | xargs git branch -d'

# Sync mint with google sheets
function finsync
{
	finpath=~/Documents/personal/finance-project
	dotnet $finpath/bin/FinancePipeline.dll \
		hiroyagojo@gmail.com $MINT_PASS \
		--google-cred-path "$finpath/finance-pipeline-325808-36b341a22811.json" \
		--filter-path "$finpath/filter.csv" \
		--spreadsheet-id "1pNs9XrzAQsuizWVbvq4D5yDQ4nESZpw--V7kI6tT91E" \
		--category-path "$finpath/category-file.json"
}

# Display all extensions in folder (use -r for recursive, -a for hidden, -d for custom directory)
function extc()
{
	lsflags=''
	dirpath=$(pwd)
	while getopts "ard:" flag; do
		case "${flag}" in
			r) lsflags=${lsflags}R ;;
			a) lsflags=${lsflags}a ;;
			d) dirpath=${OPTARG} ;;
		esac
	done

	ls -p${lsflags} $dirpath | grep -v / | grep -v -e '^$' | perl -ne 'print lc' | awk -F . '{print $NF}' | sort | uniq -c | sort
}

# Performs brew maintenance
function brewing()
{
	brew update
	brew upgrade
	brew cleanup
}

# Reload zshrc file
alias rezsh='source ~/.zshrc'

# Display all commands
alias cmds='dir=~/PersonalCode/dotfiles; ~/PersonalCode/scripts/cmds.rb $dir/zpersonal.zshrc $dir/zsecret.zshrc $dir/zwork.zshrc'

# Install vim vundle plugins
alias vimplugin='vim +PluginInstall +qall'

