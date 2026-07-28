###########
# Ansible #
###########

# install
sudo apt update
sudo apt install -y ansible
ansible --version


# Setting Up SSH Key Authentication
ssh-keygen -t ed25519 -C "ansible-control-node" -f ~/.ssh/ansible_key
# Set correct permissions on the private key
chmod 600 ~/.ssh/ansible_key

# Copy SSH key to a single managed node
# Replace 'username' with your actual username and 'server_ip' with the target IP
ssh-copy-id -i ~/.ssh/ansible_key.pub username@server_ip


cat << EOF >> ~/.ssh/config

# Ansible managed servers configuration
Host ansible-*
    User ubuntu
    IdentityFile ~/.ssh/ansible_key
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

# Specific server aliases
Host db-server-1
    HostName 192.168.1.11
    User ubuntu
    IdentityFile ~/.ssh/ansible_key
EOF


# test SSH Connection
ssh ubuntu@3.70.47.150 -i ~/projects/aws_iac_pipeline/ansible/keys/ansible-key.pem "hostname && uptime"




# inventory
###########
# List all hosts in the inventory
ansible-inventory -i ansible/inventory/hosts.yml --list

# Display inventory in graph format
ansible-inventory -i ansible/inventory/hosts.yml --graph

# List hosts in a specific group
ansible-inventory -i ansible/inventory/hosts.yml --graph db-servers


# Basic syntax: ansible <pattern> -i <inventory> -m <module> -a "<arguments>"

# Test connectivity to all hosts
ansible all -i ansible/inventory/hosts.yml -m ping
ansible dbserver -i ansible/inventory/hosts.yml -m ping

# Execute a shell command on all hosts
ansible all -i ansible/inventory/hosts.yml -m shell -a "uptime"

# Check disk space on database servers
ansible db-servers -i inventory/hosts.yml -m shell -a "df -h"