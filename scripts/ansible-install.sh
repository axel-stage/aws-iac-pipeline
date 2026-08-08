#!/bin/bash
set -e

if [[ -d "ansible/" ]]
then
  echo -e  "Ansible exists allready\nExit script!"
  exit 1
else
  echo "Starting to install Ansible!"
fi

# Create Ansible project directory
mkdir -p ansible/{inventory,keys,playbooks,roles,group_vars,host_vars}

# Navigate to the project directory
cd ansible && pwd

# Create a virtual environment for Ansible (optional but recommended)
python3 -m venv .venv --prompt ansible

# activate venv
source .venv/bin/activate

# Install Ansible using pip
pip install ansible ansible-dev-tools

# ansible cfg
cat <<EOF > ./ansible/ansible.cfg
[defaults]
inventory = inventory/hosts.yml
host_key_checking = False
stdout_callback = yaml
callback_enabled = timer

[inventory]
enable_plugins = host_list, script, auto, yaml, ini, toml
EOF

echo -e  "Finished Ansible installation!\nPath: $(which ansible)\n$(ansible --version)"