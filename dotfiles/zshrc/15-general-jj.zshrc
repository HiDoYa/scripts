# TITLE: Jujutsu

alias remove-empty-lines='sed "/^$/d"'

# JJ: Colocate git repo and track trunk
function jj-init() {
	jj git init --colocate && jj git fetch
	trunk=$(jj-trunk)
	if [[ -z "$trunk" ]]; then
		echo "No trunk found (master|main)"
	fi
	jj bookmark track $trunk@origin
}

# JJ: Get closest bookmark to self (bookmark proximity)
function jj-prox() {
	jj log -r '::@ & bookmarks()' -T 'bookmarks.map(|c| c.name() ).join("\n") ++ "\n"' --no-graph -n 1 | uniq | remove-empty-lines | head -n 1
}

# JJ: Get trunk bookmark (master|main)
function jj-trunk() {
	bookmarks=$(jj bookmark list -T 'name ++ "\n"' | remove-empty-lines)
	echo "$bookmarks" | grep -E "^(master|main)$"
}

# JJ: Move closest bookmark to current position
function jj-tug() {
	# Contains duplicates since bookmarks with @origin are also in history
	closest_bookmark=$(jj-prox)
	closest_bookmark_is_trunk=$(echo $closest_bookmark | grep -E "^(master|main)$")
	if [[ -n "${closest_bookmark_is_trunk}" ]]; then
		echo "Close bookmark not found"
		return
	fi

	jj bookmark move "${closest_bookmark}" --to @
}

# JJ: Open MR based on bookmark
function jj-openmr() {
	closest_bookmark=$(jj-prox)
	closest_bookmark_is_trunk=$(echo $closest_bookmark | grep -E "^(master|main)$")
	if [[ -n "${closest_bookmark_is_trunk}" ]]; then
		echo "Close bookmark not found"
		return
	fi

	project_id=$(glab repo view -F json | jq '.id')
	mr_already_exists=$(curl --silent -X GET \
		-H "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
		-H "Content-Type: application/json" \
		"${GITLAB_BASE_URL}/api/v4/projects/${project_id}/merge_requests?source_branch=${closest_bookmark}&state=opened" | jq -r '.[0].web_url | select(.!=null)')

	if [[ -z "$mr_already_exists" ]]; then
		echo "Merge request does not exist."
		return
	fi

	echo "$mr_already_exists"
	open "$mr_already_exists"
}

# JJ: Create new MR based on bookmark (optional flag: --draft)
function jj-newmr() {
	local draft_flag=false

	# Parse arguments
	while [[ $# -gt 0 ]]; do
		case $1 in
			--draft)
				draft_flag=true
				shift
				;;
			*)
				echo "Unknown option: $1"
				return 1
				;;
		esac
	done

	closest_bookmark=$(jj-prox)
	closest_bookmark_is_trunk=$(echo $closest_bookmark | grep -E "^(master|main)$")
	if [[ -n "${closest_bookmark_is_trunk}" ]]; then
		echo "Close bookmark not found"
		return
	fi

	project_id=$(glab repo view -F json | jq '.id')
	mr_already_exists=$(curl --silent -X GET \
		-H "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
		-H "Content-Type: application/json" \
		"${GITLAB_BASE_URL}/api/v4/projects/${project_id}/merge_requests?source_branch=${closest_bookmark}&state=opened" | jq -r '.[] | .title')

	if [[ -n "$mr_already_exists" ]]; then
		echo "Merge request already exists."
		return
	fi

	# Prepare title with optional Draft: prefix
	local title="${closest_bookmark}"
	if [[ "$draft_flag" == true ]]; then
		title="Draft: ${closest_bookmark}"
	fi

	# Many glab-cli commands no longer work with jj (esp ones pertaining to MRs)
	# but project based ones still work fine
	created_mr=$(curl --silent -X POST \
		-H "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
		-H "Content-Type: application/json" \
		-d "{\"title\": \"${title}\", \"source_branch\": \"${closest_bookmark}\", \"target_branch\": \"$(jj-trunk)\", \"squash\": true, \"remove_source_branch\": true}" \
		"$GITLAB_BASE_URL/api/v4/projects/${project_id}/merge_requests")

	web_url=$(echo $created_mr | jq -r '.web_url')
	echo $web_url
	open $web_url
}

# JJ: Push change to bookmark at current change
function jj-push() {
	jj git push --allow-new --bookmark $(jj-prox)
}

# JJ: Move bookmark and push
function jj-tugpush() {
	closest_bookmark=$(jj-prox)
	closest_bookmark_is_trunk=$(echo $closest_bookmark | grep -E "^(master|main)$")
	if [[ -n "${closest_bookmark_is_trunk}" ]]; then
		echo "Close bookmark not found"
		return
	fi

	jj-tug
	jj-push
}

# JJ: Used to clean hanging "changes". Only used during git inits. Use with extreme caution.
function jj-clean() {
	jj abandon -r 'root():: ~ ::@ ~ immutable()'
}

# JJ: Get latest trunk and jump to it
function jj-fetch() {
	jj git fetch
	jj new $(jj-trunk)
}

# HIDE: Deprecated JJ: Sync remote, creates new change and creates bookmark
function jj-mark() {
	jj git fetch
	jj new master
	jj bookmark create $1
}
