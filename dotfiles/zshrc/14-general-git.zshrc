# Create new commit and push with message
function quickgit()
{
	git add --all
	git commit -m $1
	git push
}

# Create new commit with current branch name and push. Options supported -m (message), -n (skip precommit), -f (force)
function newqcommit()
{
	MESSAGE=""
	GITFLAGS=""
	while getopts "mnf:" flag; do
		case "${flag}" in
			m) MESSAGE=${OPTARG} ;;
			f) GITFLAGS="${GITFLAGS} -f" ;;
			n) GITFLAGS="${GITFLAGS} -n" ;;
		esac
	done

	git add --all

	if [[ $MESSAGE != "" ]]; then
		newcommit -m $MESSAGE
	else
		newcommit
	fi

	newpush $GITFLAGS
}

# Create new commit with current branch name. Options supported -m (message), -n (skip precommit)
function newcommit()
{
	MESSAGE=""
	while getopts "mn:" flag; do
		case "${flag}" in
			m) MESSAGE=${OPTARG} ;;
			n) GITFLAGS="${GITFLAGS} -n" ;;
		esac
	done

	if [[ $MESSAGE != "" ]]; then
		git commit -m $(git branch --show-current)-$MESSAGE > /dev/null
	else
		git commit -m $(git branch --show-current) > /dev/null
	fi
}

# Push with current branch name. Options supported -f (force)
function newpush()
{
	while getopts "f:" flag; do
		case "${flag}" in
			f) GITFLAGS=${OPTARG} ;;
		esac
	done

	git push ${GITFLAGS} > /dev/null || \
	git push ${GITFLAGS} --set-upstream origin $(git branch --show-current) > /dev/null
}

# Create new branch. Usage: newbranch branch-name base-branch
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
