#!/usr/bin/env bash
# Open a shell on the appserver as the airflow user, ready for the airflow CLI
# (venv activated, /opt/airflow/.env.airflow loaded).
#
# Usage: scripts/airflow-cli.sh
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${PROJECT_ROOT}/terraform"
KEY_SECRET_ID="aws-iac-pipeline/dev/ansible-private-key"
KEY="${HOME}/.ssh/aws-iac-pipeline.pem"

BASTION_HOST_EIP=$(terraform -chdir="$TF_DIR" output -raw bastion_host_eip)
APPSERVER_IP=$(terraform -chdir="$TF_DIR" output -raw appserver_ip)

# Fetch the SSH key if not present
if [[ ! -s "$KEY" ]]; then
  (umask 077 && aws secretsmanager get-secret-value --secret-id "$KEY_SECRET_ID" \
    --query SecretString --output text > "$KEY")
fi

# With -J, "-i" would not apply to the bastion hop, so use ProxyCommand
PROXY="ssh -i ${KEY} -W %h:%p ubuntu@${BASTION_HOST_EIP}"

exec ssh -t -i "$KEY" -o ProxyCommand="$PROXY" "ubuntu@${APPSERVER_IP}" \
  "sudo -iu airflow bash -c 'set -a; source /opt/airflow/.env.airflow; set +a; source /opt/airflow/.venv/bin/activate; exec bash -i'"
