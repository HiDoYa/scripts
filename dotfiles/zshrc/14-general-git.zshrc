# TITLE: Git

# Create new commit and push with message
function quickgit() {
	git add --all
	git commit -m $1
	git push
}

# Create new commit with current branch name and push. Options supported -m (message), -n (skip precommit), -f (force)
function newqcommit() {
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

# Create new gitlab mr
function newmr() {
	NO_PROMPT=true glab mr create --fill --yes -t "$(git rev-parse --abbrev-ref HEAD)"
}

# Create new commit with current branch name. Options supported -m (message), -n (skip precommit)
function newcommit() {
	COMMIT_FLAGS=""

	while getopts ":n" flag; do
		case "${flag}" in
			n) COMMIT_FLAGS="-n" ;;
		esac
	done

	git commit -m "$(git branch --show-current)" ${COMMIT_FLAGS} > /dev/null
}

# Push with current branch name. Options supported -f (force)
function newpush() {
	PUSH_FLAGS=""

	while getopts ":f" flag; do
		case "${flag}" in
			f) PUSH_FLAGS="-f" ;;
		esac
	done

	git push ${PUSH_FLAGS} > /dev/null || \
	git push ${PUSH_FLAGS} --set-upstream origin "$(git branch --show-current)" > /dev/null
}

## Note: Any git command that changes current branch MUST be an alias, not a function
##       this is because my zsh otherwise will not pickup on the branch changes

# Delete merged branches
alias delmerged='git branch --merged | grep -v "(^\*|master|main|dev)" | xargs git branch -d'

# Apply current changes to master branch
alias gmaster='git checkout $(git branch --list master main | head -n 1) && git pull'
