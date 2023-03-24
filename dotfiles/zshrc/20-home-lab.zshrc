export HOMELAB_DIR=$CODE_DIR/homelab

# Startup homelab
function homelabup()
{
	ansible-playbook -i $HOMELAB_DIR/hosts.ini $HOMELAB_DIR/playbooks/lifecycle/startup.yaml
}

# Shutdown homelab
function homelabdown()
{
	ansible-playbook -i $HOMELAB_DIR/hosts.ini $HOMELAB_DIR/playbooks/lifecycle/shutdown.yaml
}