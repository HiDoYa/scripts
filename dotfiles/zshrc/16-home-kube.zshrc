# TITLE: K8s

# Local kubernetes cluster
function localk8() { unset KUBECONFIG }

# Personal kubernetes cluster
function homek8() { export KUBECONFIG=$HOME/.kube/homeconfig }
