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


# Turn node1 on
alias node1on="ansible-playbook -i $HOMELAB_DIR/hosts.ini $HOMELAB_DIR/playbooks/lifecycle/startup.yaml -e 'node=node1'"
# Turn node2 on
alias node2on="ansible-playbook -i $HOMELAB_DIR/hosts.ini $HOMELAB_DIR/playbooks/lifecycle/startup.yaml -e 'node=node2'"
# Turn node3 on
alias node3on="ansible-playbook -i $HOMELAB_DIR/hosts.ini $HOMELAB_DIR/playbooks/lifecycle/startup.yaml -e 'node=node3'"

# Turn node1 off
alias node1off="ansible-playbook -i $HOMELAB_DIR/hosts.ini $HOMELAB_DIR/playbooks/lifecycle/shutdown.yaml -e 'node=node1'"
# Turn node2 off
alias node2off="ansible-playbook -i $HOMELAB_DIR/hosts.ini $HOMELAB_DIR/playbooks/lifecycle/shutdown.yaml -e 'node=node2'"
# Turn node3 off
alias node3off="ansible-playbook -i $HOMELAB_DIR/hosts.ini $HOMELAB_DIR/playbooks/lifecycle/shutdown.yaml -e 'node=node3'"