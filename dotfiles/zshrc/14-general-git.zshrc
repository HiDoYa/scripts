# TITLE: Git

# Push all changes to current branch
function g-basic() {
	git add --all
	git commit -m $1
	git push
}

# Create commit from branch name. Options: -m (message), -n (skip hooks)
function g-commit() {
	COMMIT_FLAGS=""

	while getopts ":n" flag; do
		case "${flag}" in
			n) COMMIT_FLAGS="-n" ;;
		esac
	done

	git commit -m "$(git branch --show-current)" ${COMMIT_FLAGS} > /dev/null
}

# Push with branch name. Options: -f (force)
function g-push() {
	PUSH_FLAGS=""

	while getopts ":f" flag; do
		case "${flag}" in
			f) PUSH_FLAGS="-f" ;;
		esac
	done

	git push ${PUSH_FLAGS} > /dev/null || \
	git push ${PUSH_FLAGS} --set-upstream origin "$(git branch --show-current)" > /dev/null
}

# g-commit and g-push combined. Options: -m (message), -n (skip hooks), -f (force)
function g-quick() {
	COMMIT_FLAGS=""
	PUSH_FLAGS=""

	while getopts ":nf" flag; do
		case "${flag}" in
			n) COMMIT_FLAGS="-n" ;;
			f) PUSH_FLAGS="-f" ;;
		esac
	done

	git add --all

	newcommit ${COMMIT_FLAGS}
	newpush ${PUSH_FLAGS}
}

## Note: Any git command that changes current branch MUST be an alias, not a function
##       this is because my zsh otherwise will not pickup on the branch changes

# Delete merged branches
alias g-delmerged='git branch --merged | grep -v "(^\*|master|main|dev)" | xargs git branch -d'

# Get trunk branch
alias g-trunk='git checkout $(git branch --list master main | head -n 1) && git pull'
