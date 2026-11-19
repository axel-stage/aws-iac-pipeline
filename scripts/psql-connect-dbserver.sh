#!/usr/bin/env bash
# Open a psql session to the dbserver through an SSH tunnel via the bastion.
#
# Usage: scripts/psql-dbserver.sh [profile] [psql args...]
#   profile: postgres_root (default) | postgres_admin | postgres_reader | airflow_meta
#
# The tunnel terminates on the dbserver itself (localhost:5432), so no extra
# security group rule for port 5432 is needed.
set -euo pipefail

PROFILE="${1:-postgres_root}"
shift || true

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${PROJECT_ROOT}/terraform"
SECRET_ID="aws-iac-pipeline/dev/secret"
KEY_SECRET_ID="aws-iac-pipeline/dev/ansible-private-key"
KEY="${HOME}/.ssh/aws-iac-pipeline.pem"
SSH_USER="ubuntu"
LOCAL_PORT="${LOCAL_PORT:-5432}"

for cmd in aws terraform jq ssh psql; do
  command -v "$cmd" >/dev/null || { echo "Missing required command: $cmd" >&2; exit 1; }
done

case "$PROFILE" in
  postgres_root|postgres_admin|postgres_reader|airflow_meta) ;;
  *) echo "Unknown profile: $PROFILE" >&2; exit 1 ;;
esac

BASTION_HOST_EIP=$(terraform -chdir="$TF_DIR" output -raw bastion_host_eip)
DBSERVER_IP=$(terraform -chdir="$TF_DIR" output -raw dbserver_ip)

# Fetch the SSH key if not present
if [[ ! -s "$KEY" ]]; then
  umask 077
  aws secretsmanager get-secret-value --secret-id "$KEY_SECRET_ID" \
    --query SecretString --output text > "$KEY"
  chmod 600 "$KEY"
fi

# Fetch DB credentials for the chosen profile
CREDS=$(aws secretsmanager get-secret-value --secret-id "$SECRET_ID" \
  --query SecretString --output text | jq -e ".${PROFILE}")
DB_USER=$(jq -r '.db_role' <<<"$CREDS")
DB_NAME=$(jq -r '.db_name' <<<"$CREDS")
DB_PORT=$(jq -r '.db_port' <<<"$CREDS")
DB_PASS=$(jq -r '.db_pass' <<<"$CREDS")

# Start the tunnel in the background using an SSH control socket
CTRL_SOCK=$(mktemp -u "/tmp/psql-tunnel-XXXXXX.sock")
PROXY="ssh -i ${KEY} -o StrictHostKeyChecking=accept-new -W %h:%p ${SSH_USER}@${BASTION_HOST_EIP}"

cleanup() { ssh -S "$CTRL_SOCK" -O exit "${SSH_USER}@${DBSERVER_IP}" 2>/dev/null || true; }
trap cleanup EXIT

ssh -i "$KEY" \
  -o ProxyCommand="$PROXY" \
  -o StrictHostKeyChecking=accept-new \
  -o ExitOnForwardFailure=yes \
  -M -S "$CTRL_SOCK" -fN \
  -L "${LOCAL_PORT}:localhost:${DB_PORT}" \
  "${SSH_USER}@${DBSERVER_IP}"

echo "Tunnel open: localhost:${LOCAL_PORT} -> ${DBSERVER_IP}:${DB_PORT} (user ${DB_USER}, db ${DB_NAME})"

PGPASSWORD="$DB_PASS" PGSSLMODE=require \
  psql -h localhost -p "$LOCAL_PORT" -U "$DB_USER" -d "$DB_NAME" "$@"
