#!/bin/bash
set -e

DB_HOST_PUBLIC=
SECRET_ROLE_KEY=postgres_admin

secret_string=$(
  aws secretsmanager get-secret-value \
    --secret-id aws-iac-pipeline/dev/secret \
    --query SecretString \
    --output text
)

export PGPASSWORD=$(echo ${secret_string} | jq ".${SECRET_ROLE_KEY}.db_pass")
export DB_PORT=$(echo ${secret_string} | jq ".${SECRET_ROLE_KEY}.db_port")
export DB_NAME=$(echo ${secret_string} | jq ".${SECRET_ROLE_KEY}.db_name")
export DB_ROLE=$(echo ${secret_string} | jq ".${SECRET_ROLE_KEY}.db_role")
export PGSSLMODE=require

psql --host ${DB_HOST_PUBLIC} --port ${DB_PORT} --dbname ${DB_NAME} --username ${DB_ROLE} --no-password

# connection settings
\timing
\pset null NULL
\pset linestyle unicode
\pset unicode_border_linestyle single
\pset unicode_column_linestyle single
\pset unicode_header_linestyle double
\pset format wrapped
\pset columns 0
\! clear
