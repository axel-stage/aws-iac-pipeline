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
#####
ssh ubuntu@3.66.236.183 -i ansible/keys/ansible-key.pem


# inventory
###########
# List all hosts in the inventory
ansible-inventory --list
ansible-inventory -i inventory/hosts.yml --list

# Display inventory in graph format
ansible-inventory --graph

# List hosts in a specific group
ansible-inventory --graph dbserver

# basic
#######
# Basic syntax: ansible <pattern> -i <inventory> -m <module> -a "<arguments>"

# test connectivity to all hosts
ansible all -m ping
# to specific host
ansible dbserver -m ping
# run commands on remote machines
ansible dbserver -m command -a uptime
# short form
ansible dbserver -a uptime
# privilage accesss
ansible dbserver -b -a "tail /var/log/syslog"

# install a nginx package
ansible appserver -b -m package -a name=nginx









# Execute a shell command on all hosts
ansible all -i inventory/hosts.yml -m shell -a "uptime"

# Check disk space on database servers
ansible dbserver -i inventory/hosts.yml -m shell -a "df -h"



# troubleshooting
#################

# user
ansible dbserver -i inventory/hosts.yml -m shell -a "whoami"

# Verify PostgreSQL version
ansible dbserver -i inventory/hosts.yml -m shell -a "psql --version"
ansible dbserver -i inventory/hosts.yml -m shell -a "sudo -u postgres psql -c 'SELECT version();'"
ansible dbserver -i inventory/hosts.yml -m shell -a "sudo -u postgres psql -s localhost -d postgres"


# Check PostgreSQL service status
ansible dbserver -i inventory/hosts.yml -m shell -a "sudo systemctl status postgresql"
# Check if PostgreSQL is listening on the default port
ansible dbserver -i inventory/hosts.yml -m shell -a "sudo ss -tlnp | grep 5432"


# check data dir
ansible dbserver -i inventory/hosts.yml -m shell -a "sudo ls -la /var/lib/postgresql/18/main"
# check config dir
ansible dbserver -i inventory/hosts.yml -m shell -a "sudo ls -la /etc/postgresql/18/main"
# check binary dir
ansible dbserver -i inventory/hosts.yml -m shell -a "sudo ls -la /usr/lib/postgresql/18/bin"
# log dir
ansible dbserver -i inventory/hosts.yml -m shell -a "sudo ls -la /var/log/postgresql"


ansible dbserver -i inventory/hosts.yml -m shell -a "sudo tail -50 /var/log/postgresql/postgresql-18-main.log"
ansible dbserver -i inventory/hosts.yml -m shell -a "sudo cat /var/log/postgresql/postgresql-18-main.log"

ansible dbserver -i inventory/hosts.yml -m shell -a "sudo cat /var/lib/postgresql/18/main/log/postgresql-2026-07-31_153353.log"

# status
ansible dbserver -i inventory/hosts.yml -m shell -a "sudo systemctl status postgresql"
# restart
ansible dbserver -i inventory/hosts.yml -m shell -a "sudo systemctl restart postgresql"

ansible dbserver -i inventory/hosts.yml -m shell -a "sudo ls -la /var/lib/postgresql/18/main/"
ansible dbserver -i inventory/hosts.yml -m shell -a "sudo ls -la /etc/postgresql/18/main/"

ansible dbserver -i inventory/hosts.yml -m shell -a "sudo -u postgres psql --version"



# playbooks
###########
# Install PostgreSQL on all database servers
ansible-playbook playbooks/install-postgresql.yml -i inventory/hosts.yml
# Apply PostgreSQL configuration to all database servers
ansible-playbook playbooks/configure-postgresql.yml -i inventory/hosts.yml

# Install on all application servers
ansible-playbook playbooks/install-airflow.yml -i inventory/hosts.yml
# Apply Ansible configuration to all app servers
ansible-playbook playbooks/configure-airflow.yml -i inventory/hosts.yml




# Preview changes without applying (check mode)
ansible-playbook playbooks/configure-postgresql.yml -i inventory/hosts.yml --check --diff

# check postgresql.conf
ansible dbserver -i inventory/hosts.yml -m shell -a "sudo cat /etc/postgresql/18/main/postgresql.conf"
# check pg_hba.conf
ansible dbserver -i inventory/hosts.yml -m shell -a "sudo cat /etc/postgresql/18/main/pg_hba.conf"



ansible dbserver -i inventory/hosts.yml -m shell -a "sudo -u postgres psql -c \"SELECT CURRENT_DATE;\""

#


ansible dbserver -i inventory/hosts.yml -m shell -a "sudo -u postgres psql -t -c \"SELECT pg_reload_conf();\""
ansible dbserver -i inventory/hosts.yml -m shell -a "sudo -u postgres psql -t -c \"SHOW shared_buffers;\""



ansible dbserver -i inventory/hosts.yml -m shell -a "sudo -u postgres psql -h localhost -d postgres -U postgres"

