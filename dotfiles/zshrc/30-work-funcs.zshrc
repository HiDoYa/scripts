export PATH=$HOME/.dotnet/tools:$PATH

# Jira: create ticket
alias jticket="jticket"
# Jira: sprint list (interactive)
alias j-sprint="jira sprint list -a$(jira me)"
# Jira: add comment to ticket
alias j-comment="jira issue comment add"

# View one time password
function otp() {
  $CODE_DIR/otp-cli/otp-cli show -c work_token
}

# Update version in changelog and poetry
function pvupdate()
{
	changelog-inc $1
	poetry version $1
}

# Update version in changelog and VERSION file
function vupdate()
{
	changelog-inc $1
  echo -n "v$1" > VERSION
}

# Login to awx cli
function awxlogin() {
  eval "$(awx login -f human)"
}

# Work kubernetes cluster
function workk8() {
    export KUBECONFIG=$HOME/.kube/workconfig
    export KUBE_CONFIG_PATH=${KUBECONFIG}
}

# List roles in nbcli
alias nbcliroles='nbcli shell -c "nbprint(DeviceRole.all())"'

workk8