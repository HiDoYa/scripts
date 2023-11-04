# Local kubernetes cluster
function localk8() { unset KUBECONFIG }
# Work kubernetes cluster
function workk8() {
    export KUBECONFIG=$HOME/.kube/workconfig
    export KUBE_CONFIG_PATH=${KUBECONFIG}
}
# Personal kubernetes cluster
function homek8() { export KUBECONFIG=$HOME/.kube/homeconfig }

export KUBECONFIG=$HOME/.kube/config
