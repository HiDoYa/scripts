# Local kubernetes cluster
function localk8() { unset KUBECONFIG; echo workk8 activated }
# Work kubernetes cluster
function workk8() { export KUBECONFIG=$HOME/.kube/workconfig; echo workk8 activated }
# Personal kubernetes cluster
function homek8() { export KUBECONFIG=$HOME/.kube/homeconfig; echo homek8 activated }

export KUBECONFIG=$HOME/.kube/config
