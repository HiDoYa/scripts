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

# Watch for pipeline finish/stall
function watchpipeline() {
	TMP_FNAME="/tmp/glpipeline.json"
	while true; do
		# Control characters mess stuff up when saving into vars and Im too lazy to troubleshoot it
		glab ci get --output json > ${TMP_FNAME}

		pipeline_status=$(cat ${TMP_FNAME} | jq -r '.detailed_status.text')
		if [[ "$pipeline_status" != "Running" ]]; then
			pipeline_status_label=$(cat ${TMP_FNAME} | jq -r '.detailed_status.label')
			echo "Pipeline status: ${pipeline_status} - ${pipeline_status_label}"

			pipeline_job_results=$(cat ${TMP_FNAME} | jq -r '.jobs.[] | {status, name} | join(": ")')

			echo ""
			echo "Status:"
			echo $pipeline_job_results

			# Play twice because it sounds nicer
			afplay /System/Library/Sounds/Funk.aiff
			afplay /System/Library/Sounds/Funk.aiff
			break
		fi

		pipeline_job_running=$(cat ${TMP_FNAME} | jq -r '[.jobs.[] | {name, status} | select(.status == "running")] | map(.name) | join(", ")')
		echo "Currently running: ${pipeline_job_running}"
		sleep 10
	done
}

# View logs for pipeline failures
function pipelinefailure() {
	TMP_FNAME="/tmp/glpipeline_failure.json"
	HEADER_WIDTH=56

	glab ci get --output json > ${TMP_FNAME}
	project_id=$(cat ${TMP_FNAME} | jq -r '.project_id')
	pipeline_failed_jobs=$(cat ${TMP_FNAME} | jq -r '[.jobs.[] | {name, status} | select(.status == "failed")] | map(.name) | join(", ")')
	if [[ -z "${pipeline_failed_jobs}" ]]; then
		echo "No failed jobs found"
		return
	fi

	echo "Failed jobs:"
	echo $pipeline_failed_jobs
	printf '%*s\n' "$HEADER_WIDTH" '' | tr ' ' '-'
	jq -c '.jobs[] | select(.status == "failed") | {id, name}' "${TMP_FNAME}" | while read -r job; do
		job_id=$(echo "$job" | jq -r '.id')
		job_name=$(echo "$job" | jq -r '.name')

		# Used to just make dashes the same length
		name_length=${#job_name}
		dash_total=$((HEADER_WIDTH - name_length - 2))
		dash_left=$((dash_total / 2))
		dash_right=$((dash_total - dash_left))
		printf '%*s %s %*s\n' "$dash_left" '' "$job_name" "$dash_right" '' | tr ' ' '-'

		printf '%*s\n' "$HEADER_WIDTH" '' | tr ' ' '-'
		curl --silent --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
			"${GITLAB_BASE_URL}/api/v4/projects/${project_id}/jobs/${job_id}/trace"
		printf '%*s\n' "$HEADER_WIDTH" '' | tr ' ' '-'
	done
}


# Open gitlab MR associated with current branch (assumes only 1 MR)
function openmr() {
	open "$(glab mr list --output json | jq -r '.[0].web_url')"
}

# Create new gitlab mr
function newmr() {
	MR_CREATE_OUTPUT=$(NO_PROMPT=true glab mr create --fill --yes -t "$(git rev-parse --abbrev-ref HEAD)")
	echo $MR_CREATE_OUTPUT
	open "$(echo $MR_CREATE_OUTPUT | grep "https://gitlab.adsrvr.org")"
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
