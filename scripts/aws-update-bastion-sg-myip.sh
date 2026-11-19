#!/usr/bin/env bash
# Point the bastion SG's "local-admin-ssh" rule at my current public IPv4.
# Previous local-admin-ssh rules are revoked first, so old IPs don't pile up.
#
# Usage: scripts/aws-update-bastion-sg-myip.sh [--revoke]
#   --revoke   only remove local-admin-ssh rules, don't add a new one
#
# Note: the bastion SG defines its ingress inline in Terraform, so the next
# `terraform apply` removes this rule again. Re-run the script after an apply.
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SSH_PORT="${SSH_PORT:-22}"
DESC="local-admin-ssh"

for cmd in aws terraform curl; do
  command -v "$cmd" >/dev/null || { echo "Missing required command: $cmd" >&2; exit 1; }
done

SG_ID=$(terraform -chdir="${PROJECT_ROOT}/terraform" output -raw bastion_sg_id)

# Resolve the IP before touching the SG, so a failed lookup changes nothing
if [[ "${1:-}" != "--revoke" ]]; then
  MY_IP=$(curl -sf --max-time 5 https://checkip.amazonaws.com | tr -d '[:space:]')
  [[ "$MY_IP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] \
    || { echo "Could not determine public IPv4 (got '${MY_IP}')" >&2; exit 1; }
fi

# Revoke all earlier rules with our description
read -r -a OLD_RULES <<<"$(aws ec2 describe-security-group-rules \
  --filters "Name=group-id,Values=${SG_ID}" \
  --query "SecurityGroupRules[?!IsEgress && Description=='${DESC}'].SecurityGroupRuleId" \
  --output text)"

if (( ${#OLD_RULES[@]} > 0 )); then
  aws ec2 revoke-security-group-ingress --group-id "$SG_ID" \
    --security-group-rule-ids "${OLD_RULES[@]}" >/dev/null
  echo "Revoked ${#OLD_RULES[@]} old rule(s) from ${SG_ID}"
fi

[[ "${1:-}" == "--revoke" ]] && exit 0

aws ec2 authorize-security-group-ingress --group-id "$SG_ID" \
  --ip-permissions "IpProtocol=tcp,FromPort=${SSH_PORT},ToPort=${SSH_PORT},IpRanges=[{CidrIp=${MY_IP}/32,Description=${DESC}}]" \
  >/dev/null

echo "Allowed ${MY_IP}/32 on tcp/${SSH_PORT} in ${SG_ID}"
