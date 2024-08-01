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
	COMMIT_FLAGS=""
	PUSH_FLAGS=""

	while getopts "m:nf" flag; do
		case "${flag}" in
			m) MESSAGE="${OPTARG}" ;;
			n) COMMIT_FLAGS="-n" ;;
			f) PUSH_FLAGS="-f" ;;
		esac
	done

	git add --all

	if [[ -n $MESSAGE ]]; then
		$COMMIT_FLAGS="${COMMIT_FLAGS} -m ${MESSAGE}"
	fi

	newcommit "${COMMIT_FLAGS}"
	newpush "${PUSH_FLAGS}"
}


# Create new commit with current branch name. Options supported -m (message), -n (skip precommit)
function newcommit()
{
	MESSAGE=""
	COMMIT_FLAGS=""

	while getopts "m:n" flag; do
		case "${flag}" in
			m) MESSAGE=${OPTARG} ;;
			n) COMMIT_FLAGS="-n" ;;
		esac
	done

	if [[ $MESSAGE != "" ]]; then
		git commit -m "$(git branch --show-current)-${MESSAGE}" "${COMMIT_FLAGS}" > /dev/null
	else
		git commit -m "$(git branch --show-current)" "${COMMIT_FLAGS}" > /dev/null
	fi
}

# Push with current branch name. Options supported -f (force)
function newpush()
{
	PUSH_FLAGS=""

	while getopts ":f" flag; do
		case "${flag}" in
			f) PUSH_FLAGS="-f" ;;
		esac
	done

	git push "${PUSH_FLAGS}" > /dev/null || \
	git push "${PUSH_FLAGS}" --set-upstream origin "$(git branch --show-current)" > /dev/null
}

# Create new branch. Usage: newbranch branch-name base-branch
function newbranch()
{
	if [[ $2 ]]; then
		git checkout "$2"
	else
		git checkout master
	fi

	git pull
	git checkout -b "$1"
}

# Delete merged branches
alias delmerged='git branch --merged | egrep -v "(^\*|master|main|dev)" | xargs git branch -d'
