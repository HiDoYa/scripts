# Jira: sprint list (interactive)
alias j-sprint="jira sprint list -a$(jira me)"
# Jira: add comment to ticket
alias j-comment="jira issue comment add"

# View one time password
function otp() {
  otp-cli show work_token
}

# Update version in changelog and poetry
function pvupdate()
{
	changelog-inc $1
	poetry version $1
}

# Login to awx cli
function awxlogin() {
  awx login -f human
}

# Work kubernetes cluster
function workk8() {
    export KUBECONFIG=$HOME/.kube/workconfig
    export KUBE_CONFIG_PATH=${KUBECONFIG}
}

workk8