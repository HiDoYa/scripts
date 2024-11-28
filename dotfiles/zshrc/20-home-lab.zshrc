export HOMELAB_DIR=$CODE_DIR/homelab

# Startup homelab
function homelabup()
{
	ansible-playbook -i $HOMELAB_DIR/ansible/hosts.ini $HOMELAB_DIR/ansible/playbooks/lifecycle/startup.yaml --ask-become-pass
}

# Shutdown homelab
function homelabdown()
{
	ansible-playbook -i $HOMELAB_DIR/ansible/hosts.ini $HOMELAB_DIR/ansible/playbooks/lifecycle/shutdown.yaml
}


# Turn node1 on
alias node1on="ansible-playbook -i $HOMELAB_DIR/ansible/hosts.ini $HOMELAB_DIR/ansible/playbooks/lifecycle/startup.yaml -e 'node=node1' --ask-become-pass"
# Turn node2 on
alias node2on="ansible-playbook -i $HOMELAB_DIR/ansible/hosts.ini $HOMELAB_DIR/ansible/playbooks/lifecycle/startup.yaml -e 'node=node2' --ask-become-pass"
# Turn node3 on
alias node3on="ansible-playbook -i $HOMELAB_DIR/ansible/hosts.ini $HOMELAB_DIR/ansible/playbooks/lifecycle/startup.yaml -e 'node=node3' --ask-become-pass"
# Turn node4 on
alias node4on="ansible-playbook -i $HOMELAB_DIR/ansible/hosts.ini $HOMELAB_DIR/ansible/playbooks/lifecycle/startup.yaml -e 'node=node4' --ask-become-pass"

# Turn node1 off
alias node1off="ansible-playbook -i $HOMELAB_DIR/ansible/hosts.ini $HOMELAB_DIR/ansible/playbooks/lifecycle/shutdown.yaml -e 'node=node1'"
# Turn node2 off
alias node2off="ansible-playbook -i $HOMELAB_DIR/ansible/hosts.ini $HOMELAB_DIR/ansible/playbooks/lifecycle/shutdown.yaml -e 'node=node2'"
# Turn node3 off
alias node3off="ansible-playbook -i $HOMELAB_DIR/ansible/hosts.ini $HOMELAB_DIR/ansible/playbooks/lifecycle/shutdown.yaml -e 'node=node3'"
# Turn node3 off
alias node4off="ansible-playbook -i $HOMELAB_DIR/ansible/hosts.ini $HOMELAB_DIR/ansible/playbooks/lifecycle/shutdown.yaml -e 'node=node4'"

# Show node docker ports
alias nodeports="nodecmds \"docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'\""

# Run command in all nodes
function nodecmds() {
	export RED=$(tput setaf 1 :-"" 2>/dev/null)
	export GREEN=$(tput setaf 2 :-"" 2>/dev/null)
	export YELLOW=$(tput setaf 3 :-"" 2>/dev/null)
	export BLUE=$(tput setaf 4 :-"" 2>/dev/null)
	export RESET=$(tput sgr0 :-"" 2>/dev/null)

    for node in node1 node2 node3 node4; do
        echo "$node"
		echo "-----"
        ssh "$node" $@
		echo $RED; printf -- "-%.0s" $(seq $(tput cols)); echo $RESET
    done
}