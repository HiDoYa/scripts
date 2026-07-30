# TITLE: Gitlab

# HIDE: Default branch to current jj change if in a jj repo (glab ci needs jj-prox, not jj itself)
function _gl_default_branch() {
	[[ -d .jj ]] && jj-prox
}

# HIDE: Fetch pipeline JSON for branch/repo into tmp_fname, echoing the command for visibility
function _gl_fetch_pipeline() {
	local branch="$1" repo="$2" tmp_fname="$3"
	echo "glab ci get -b ${branch} ${repo} --output json > ${tmp_fname}"
	glab ci get -b ${branch} ${repo} --output json > ${tmp_fname}
}

# HIDE: Report pipeline status; returns 0 once done (and notifies), 1 while Running/Pending
function _gl_pipeline_report_if_done() {
	local tmp_fname="$1"
	local pipeline_status=$(jq -r '.detailed_status.text' ${tmp_fname})
	if [[ "$pipeline_status" == "Running" || "$pipeline_status" == "Pending" ]]; then
		local pipeline_job_running=$(jq -r '[.jobs.[] | {name, status} | select(.status == "running")] | map(.name) | join(", ")' ${tmp_fname})
		echo "Currently running: ${pipeline_job_running}"
		return 1
	fi

	local pipeline_status_label=$(jq -r '.detailed_status.label' ${tmp_fname})
	echo "Pipeline status: ${pipeline_status} - ${pipeline_status_label}"

	local pipeline_job_results=$(jq -r '.jobs.[] | {status, name} | join(": ")' ${tmp_fname})
	echo ""
	echo "Status:"
	echo $pipeline_job_results

	notify "Pipeline completed"
	return 0
}

# Watch for pipeline finish/stall (e.g. gl-watch -b <branch_name> -R <repo_name>)
function gl-watch() {
	local branch_name=$(_gl_default_branch)
	local repo_flag=""

	# Parse optional flags
	while [[ $# -gt 0 ]]; do
		case $1 in
			-b|--branch)
				branch_name="$2"
				shift 2
				;;
			-R|--repo)
				# Use var since it can be company repo
				repo_flag="-R $GITLAB_BASE$2"
				shift 2
				;;
			*)
				echo "Unknown option: $1"
				echo "Usage: gl-watch [-b|--branch BRANCH_NAME] [-R|--repo REPO]"
				return 1
				;;
		esac
	done

	if [[ -z "$branch_name" ]]; then
		echo "Error: No .jj directory found and -b flag not specified"
		echo "Usage: gl-watch [-b|--branch BRANCH_NAME] [-R|--repo REPO]"
		return 1
	fi

	TMP_FNAME="/tmp/glpipeline.json"
	while true; do
		_gl_fetch_pipeline "${branch_name}" "${repo_flag}" ${TMP_FNAME}

		if _gl_pipeline_report_if_done ${TMP_FNAME}; then
			break
		fi
		sleep 10
	done
}

# Watch a pipeline and auto-trigger specified manual jobs as they become available (e.g. gl-watch-auto -b <branch_name> -R <repo_name> -j <job_name> -j <job_name2>)
function gl-watch-auto() {
	local branch_name=$(_gl_default_branch)
	local repo_flag=""
	local run_jobs=()

	# Parse optional flags
	while [[ $# -gt 0 ]]; do
		case $1 in
			-b|--branch)
				branch_name="$2"
				shift 2
				;;
			-R|--repo)
				# Use var since it can be company repo
				repo_flag="-R $GITLAB_BASE$2"
				shift 2
				;;
			-j|--job)
				run_jobs+=("$2")
				shift 2
				;;
			*)
				echo "Unknown option: $1"
				echo "Usage: gl-watch-auto [-b|--branch BRANCH_NAME] [-R|--repo REPO] [-j|--job JOB_NAME]..."
				return 1
				;;
		esac
	done

	if [[ -z "$branch_name" ]]; then
		echo "Error: No .jj directory found and -b flag not specified"
		echo "Usage: gl-watch-auto [-b|--branch BRANCH_NAME] [-R|--repo REPO] [-j|--job JOB_NAME]..."
		return 1
	fi

	if [[ ${#run_jobs[@]} -eq 0 ]]; then
		echo "Error: No -j/--job specified, nothing to auto-run. Use gl-watch instead"
		echo "Usage: gl-watch-auto [-b|--branch BRANCH_NAME] [-R|--repo REPO] [-j|--job JOB_NAME]..."
		return 1
	fi

	TMP_FNAME="/tmp/glpipeline_auto.json"
	local triggered_ids=()
	while true; do
		_gl_fetch_pipeline "${branch_name}" "${repo_flag}" ${TMP_FNAME}

		# Trigger any requested manual jobs that are now available and haven't been triggered yet.
		triggered_any=false
		for job_name in "${run_jobs[@]}"; do
			job_id=$(jq -r --arg name "$job_name" '[.jobs.[] | select(.status == "manual" and .name == $name) | .id] | first // empty' ${TMP_FNAME})
			if [[ -z "$job_id" ]]; then
				continue
			fi
			if [[ " ${triggered_ids[*]} " == *" ${job_id} "* ]]; then
				continue
			fi

			echo "Triggering manual job: ${job_name} (id: ${job_id})"
			glab ci trigger "${job_id}" -b ${branch_name} ${repo_flag}
			triggered_ids+=("${job_id}")
			triggered_any=true
		done

		if [[ "$triggered_any" == true ]]; then
			sleep 5
			continue
		fi

		if _gl_pipeline_report_if_done ${TMP_FNAME}; then
			break
		fi
		sleep 10
	done
}

# View logs for pipeline failures (e.g. gl-failed -b <branch_name> -R <repo_name>)
function gl-failed() {
	local branch_name=$(_gl_default_branch)
	local repo_flag=""

	# Parse optional flags
	while [[ $# -gt 0 ]]; do
		case $1 in
			-b|--branch)
				branch_name="$2"
				shift 2
				;;
			-R|--repo)
				# Use var since it can be company repo
				repo_flag="-R $GITLAB_BASE$2"
				shift 2
				;;
			*)
				echo "Unknown option: $1"
				echo "Usage: gl-failed [-b|--branch BRANCH_NAME] [-R|--repo REPO]"
				return 1
				;;
		esac
	done

	if [[ -z "$branch_name" ]]; then
		echo "Error: No .jj directory found and -b flag not specified"
		echo "Usage: gl-failed [-b|--branch BRANCH_NAME] [-R|--repo REPO]"
		return 1
	fi

	TMP_FNAME="/tmp/glpipeline_failure.json"
	HEADER_WIDTH=56

	_gl_fetch_pipeline "${branch_name}" "${repo_flag}" ${TMP_FNAME}
	project_id=$(jq -r '.project_id' ${TMP_FNAME})
	pipeline_failed_jobs=$(jq -r '[.jobs.[] | {name, status} | select(.status == "failed")] | map(.name) | join(", ")' ${TMP_FNAME})
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
function gl-openmr() {
	open "$(glab mr list --output json | jq -r '.[0].web_url')"
}

# Create new gitlab mr
function gl-newmr() {
	MR_CREATE_OUTPUT=$(NO_PROMPT=true glab mr create --fill --yes -t "$(git rev-parse --abbrev-ref HEAD)")
	echo $MR_CREATE_OUTPUT
	open "$(echo $MR_CREATE_OUTPUT | grep "${GITLAB_BASE_URL}")"
}
