# TITLE: K8s

# Local kubernetes cluster
function k8-local() { unset KUBECONFIG }

# Personal kubernetes cluster
function k8-lab() { export KUBECONFIG=$HOME/.kube/labconfig }
