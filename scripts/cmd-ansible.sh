###########
# Ansible #
###########


# activate ansible
##################
cd ansible && pwd
source .venv/bin/activate
clear
ansible --version


# ssh
ssh ubuntu@63.184.123.49 -i keys/ansible-key.pem


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



# troubleshooting
#################

# user
ansible dbserver -i inventories/hosts.yml -m shell -a "whoami"

# Verify PostgreSQL version
ansible dbserver -i inventories/hosts.yml -m shell -a "psql --version"
ansible dbserver -i inventories/hosts.yml -m shell -a "sudo -u postgres psql -c 'SELECT version();'"
ansible dbserver -i inventories/hosts.yml -m shell -a "sudo -u postgres psql -s localhost -d postgres"


# Check PostgreSQL service status
ansible dbserver -i inventories/hosts.yml -m shell -a "sudo systemctl status postgresql"
# Check if PostgreSQL is listening on the default port
ansible dbserver -i inventories/hosts.yml -m shell -a "sudo ss -tlnp | grep 5432"


# check data dir
ansible dbserver -i inventories/hosts.yml -m shell -a "sudo ls -la /var/lib/postgresql/18/main"
# check config dir
ansible dbserver -i inventories/hosts.yml -m shell -a "sudo ls -la /etc/postgresql/18/main"
# check binary dir
ansible dbserver -i inventories/hosts.yml -m shell -a "sudo ls -la /usr/lib/postgresql/18/bin"
# log dir
ansible dbserver -i inventories/hosts.yml -m shell -a "sudo ls -la /var/log/postgresql"


ansible dbserver -i inventories/hosts.yml -m shell -a "sudo tail -50 /var/log/postgresql/postgresql-18-main.log"
ansible dbserver -i inventories/hosts.yml -m shell -a "sudo cat /var/log/postgresql/postgresql-18-main.log"

ansible dbserver -i inventories/hosts.yml -m shell -a "sudo cat /var/lib/postgresql/18/main/log/postgresql-2026-07-31_153353.log"

# status
ansible dbserver -i inventories/hosts.yml -m shell -a "sudo systemctl status postgresql"
# restart
ansible dbserver -i inventories/hosts.yml -m shell -a "sudo systemctl restart postgresql"

ansible dbserver -i inventories/hosts.yml -m shell -a "sudo ls -la /var/lib/postgresql/18/main/"
ansible dbserver -i inventories/hosts.yml -m shell -a "sudo ls -la /etc/postgresql/18/main/"

ansible dbserver -i inventories/hosts.yml -m shell -a "sudo -u postgres psql --version"



# playbooks
###########
# Install PostgreSQL on all database servers
ansible-playbook playbooks/install-postgresql.yml -i inventories/hosts.yml
# Apply PostgreSQL configuration to all database servers
ansible-playbook playbooks/configure-postgresql.yml -i inventories/hosts.yml






# Preview changes without applying (check mode)
ansible-playbook playbooks/configure-postgresql.yml -i inventories/hosts.yml --check --diff

# check postgresql.conf
ansible dbserver -i inventories/hosts.yml -m shell -a "sudo cat /etc/postgresql/18/main/postgresql.conf"
# check pg_hba.conf
ansible dbserver -i inventories/hosts.yml -m shell -a "sudo cat /etc/postgresql/18/main/pg_hba.conf"



ansible dbserver -i inventories/hosts.yml -m shell -a "sudo -u postgres psql -c \"SELECT CURRENT_DATE;\""

#


ansible dbserver -i inventories/hosts.yml -m shell -a "sudo -u postgres psql -t -c \"SELECT pg_reload_conf();\""
ansible dbserver -i inventories/hosts.yml -m shell -a "sudo -u postgres psql -t -c \"SHOW shared_buffers;\""



ansible dbserver -i inventories/hosts.yml -m shell -a "sudo -u postgres psql -h localhost -d postgres -U postgres"

