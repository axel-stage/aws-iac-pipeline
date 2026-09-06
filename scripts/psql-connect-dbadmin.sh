#!/bin/bash
set -e

# DB_HOST_PUBLIC=3.67.71.135
# SECRET_ROLE_KEY=postgres_root

# secret_string=$(
#   aws secretsmanager get-secret-value \
#     --secret-id aws-iac-pipeline/dev/secret \
#     --query SecretString \
#     --output text
# )

# export PGPASSWORD=$(echo ${secret_string} | jq ".${SECRET_ROLE_KEY}.db_pass")
# export DB_PORT=$(echo ${secret_string} | jq ".${SECRET_ROLE_KEY}.db_port")
# export DB_NAME=$(echo ${secret_string} | jq ".${SECRET_ROLE_KEY}.db_name")
# export DB_ROLE=$(echo ${secret_string} | jq ".${SECRET_ROLE_KEY}.db_role")
# export PGSSLMODE=require

# psql --host ${DB_HOST_PUBLIC} --port ${DB_PORT} --dbname ${DB_NAME} --username ${DB_ROLE} --no-password

DB_HOST_PUBLIC=3.67.71.135
DB_PORT=5432
PGSSLMODE=require

secret_string=$(
  aws secretsmanager get-secret-value \
    --secret-id aws-iac-pipeline/dev/secret \
    --query SecretString \
    --output text
)

export ADMIN_DB_ROLE=$(echo ${secret_string} | jq ".postgres_admin.db_role" | tr -d '"')
export ADMIN_DB_NAME=$(echo ${secret_string} | jq ".postgres_admin.db_name" | tr -d '"')
export PGPASSWORD=$(echo ${secret_string} | jq ".postgres_admin.db_pass" | tr -d '"')

psql --host ${DB_HOST_PUBLIC} --port ${DB_PORT} --username ${ADMIN_DB_ROLE} --dbname ${ADMIN_DB_NAME} --no-password

\timing
\pset null NULL
\pset linestyle unicode
\pset unicode_border_linestyle single
\pset unicode_column_linestyle single
\pset unicode_header_linestyle double
\pset format wrapped
\pset columns 0
\! clear
\conninfo