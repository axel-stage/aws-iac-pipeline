###########
# Ansible #
###########

# activate ansible
##################
cd ansible && pwd
source .venv/bin/activate
ansible --version
clear





# inventory
###########
# List all hosts in the inventory
ansible-inventory -i inventories/hosts.yml --list

# Display inventory in graph format
ansible-inventory -i inventories/hosts.yml --graph

# List hosts in a specific group
ansible-inventory -i inventories/hosts.yml --graph dbserver


# Basic syntax: ansible <pattern> -i <inventory> -m <module> -a "<arguments>"

# Test connectivity to all hosts
ansible all -i inventories/hosts.yml -m ping
ansible dbserver -i inventories/hosts.yml -m ping

# Execute a shell command on all hosts
ansible all -i inventories/hosts.yml -m shell -a "uptime"

# Check disk space on database servers
ansible dbserver -i inventories/hosts.yml -m shell -a "df -h"



# playbooks
###########
# Install PostgreSQL on all database servers
ansible-playbook playbooks/install-postgresql.yml -i inventories/hosts.yml dbserver