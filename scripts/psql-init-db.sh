#!/bin/bash
set -e

# # load env vars
# source .env.psql

# # connect with SSL required
# # role: root
# export PGSSLMODE=require
# export PGPASSWORD=${DB_ROOT_PASS}
# psql --host ${DB_HOST_PUBLIC} --port ${DB_PORT} --username ${DB_ROOT_ROLE} --dbname ${DB_ROOT_NAME} --no-password <<-EOSQL

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

export ADMIN_DB_ROLE=$(echo ${secret_string} | jq ".postgres_admin.db_role" | tr -d '"')
export ADMIN_DB_NAME=$(echo ${secret_string} | jq ".postgres_admin.db_name" | tr -d '"')
export ADMIN_DB_PASS=$(echo ${secret_string} | jq ".postgres_admin.db_pass" | tr -d '"')
export ADMIN_DB_CONN_LIMIT=$(echo ${secret_string} | jq ".postgres_admin.db_conn_limit" | tr -d '"')
export ADMIN_DB_SCHEMA=$(echo ${secret_string} | jq ".postgres_admin.db_schema" | tr -d '"')

export READ_DB_ROLE=$(echo ${secret_string} | jq ".postgres_reader.db_role" | tr -d '"')
export READ_DB_PASS=$(echo ${secret_string} | jq ".postgres_reader.db_pass" | tr -d '"')
export READ_DB_CONN_LIMIT=$(echo ${secret_string} | jq ".postgres_reader.db_conn_limit" | tr -d '"')

psql --host ${DB_HOST_PUBLIC} --port ${DB_PORT} --username ${ROOT_DB_ROLE} --dbname ${ROOT_DB_NAME} --no-password <<-EOSQL

\conninfo
\timing

CREATE ROLE ${ADMIN_DB_ROLE} WITH
    LOGIN
    PASSWORD '${ADMIN_DB_PASS}'
    NOCREATEDB
    NOSUPERUSER
    NOCREATEROLE
    NOINHERIT
    NOBYPASSRLS
    NOREPLICATION
    VALID UNTIL 'infinity'
    CONNECTION LIMIT ${ADMIN_DB_CONN_LIMIT};

CREATE ROLE ${READ_DB_ROLE} WITH
    LOGIN
    PASSWORD '${READ_DB_PASS}'
    NOCREATEDB
    NOSUPERUSER
    NOCREATEROLE
    NOINHERIT
    NOBYPASSRLS
    NOREPLICATION
    VALID UNTIL 'infinity'
    CONNECTION LIMIT ${READ_DB_CONN_LIMIT};

CREATE DATABASE ${ADMIN_DB_NAME} WITH
    OWNER ${ADMIN_DB_ROLE}
    ENCODING='UTF8'
    LC_COLLATE='en_US.UTF-8'
    LC_CTYPE='en_US.UTF-8'
    TEMPLATE template0;

\connect ${ADMIN_DB_NAME}
\conninfo

DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA IF NOT EXISTS ${ADMIN_DB_SCHEMA} AUTHORIZATION ${ADMIN_DB_ROLE};
SET search_path TO ${ADMIN_DB_SCHEMA};

CREATE EXTENSION IF NOT EXISTS dblink WITH
  SCHEMA ${ADMIN_DB_SCHEMA}
  VERSION '1.2';
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH
  SCHEMA ${ADMIN_DB_SCHEMA};
CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH
  SCHEMA ${ADMIN_DB_SCHEMA};

GRANT ALL PRIVILEGES ON DATABASE ${ADMIN_DB_NAME} TO ${ADMIN_DB_ROLE};
GRANT ALL ON SCHEMA ${ADMIN_DB_SCHEMA} TO ${ADMIN_DB_ROLE};

GRANT CONNECT ON DATABASE ${ADMIN_DB_NAME} TO ${READ_DB_ROLE};
GRANT USAGE ON SCHEMA ${ADMIN_DB_SCHEMA} TO ${READ_DB_ROLE};
ALTER DEFAULT PRIVILEGES
  FOR ROLE ${ADMIN_DB_ROLE} IN SCHEMA ${ADMIN_DB_SCHEMA}
      GRANT SELECT ON TABLES TO ${READ_DB_ROLE};
ALTER DEFAULT PRIVILEGES
  FOR ROLE ${ADMIN_DB_ROLE} IN SCHEMA ${ADMIN_DB_SCHEMA}
      GRANT SELECT ON SEQUENCES TO ${READ_DB_ROLE};

-- List roles
\du
-- List databases
\l
-- List schemas
\dn+

\q
EOSQL