#!/bin/bash
set -e

# # load env vars
# source .env.psql

# # connect with SSL required
# # role: root
# export PGSSLMODE=require
# export PGPASSWORD=${DB_ROOT_PASS}

DB_HOST_PUBLIC=3.67.71.135
DB_PORT=5432
PGSSLMODE=require

secret_string=$(
  aws secretsmanager get-secret-value \
    --secret-id aws-iac-pipeline/dev/secret \
    --query SecretString \
    --output text
)

export ROOT_DB_ROLE=$(echo ${secret_string} | jq ".postgres_root.db_role" | tr -d '"')
export ROOT_DB_NAME=$(echo ${secret_string} | jq ".postgres_root.db_name" | tr -d '"')
export PGPASSWORD=$(echo ${secret_string} | jq ".postgres_root.db_pass" | tr -d '"')

export META_DB_ROLE=$(echo ${secret_string} | jq ".airflow_meta.db_role" | tr -d '"')
export META_DB_NAME=$(echo ${secret_string} | jq ".airflow_meta.db_name" | tr -d '"')
export META_DB_PASS=$(echo ${secret_string} | jq ".airflow_meta.db_pass" | tr -d '"')
export META_DB_CONN_LIMIT=$(echo ${secret_string} | jq ".airflow_meta.db_conn_limit" | tr -d '"')

psql --host ${DB_HOST_PUBLIC} --port ${DB_PORT} --username ${ROOT_DB_ROLE} --dbname ${ROOT_DB_NAME} --no-password <<-EOSQL

\conninfo
\timing

CREATE ROLE ${META_DB_ROLE} WITH
    LOGIN
    PASSWORD '${META_DB_PASS}'
    NOCREATEDB
    NOSUPERUSER
    NOCREATEROLE
    NOINHERIT
    NOBYPASSRLS
    NOREPLICATION
    VALID UNTIL 'infinity'
    CONNECTION LIMIT ${META_DB_CONN_LIMIT};

CREATE DATABASE ${META_DB_NAME} WITH
    OWNER ${META_DB_ROLE}
    ENCODING='UTF8'
    LC_COLLATE='en_US.UTF-8'
    LC_CTYPE='en_US.UTF-8'
    TEMPLATE template0;

GRANT ALL PRIVILEGES ON DATABASE ${META_DB_NAME} TO ${META_DB_ROLE};
GRANT ALL ON SCHEMA public TO ${META_DB_ROLE};

SET search_path TO public;

\q
EOSQL