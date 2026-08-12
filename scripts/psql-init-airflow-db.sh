#!/bin/bash
set -e

# load env vars
source .env.psql

# connect with SSL required
# role: root
export PGSSLMODE=require
export PGPASSWORD=${DB_ROOT_PASS}
psql --host ${DB_HOST_PUBLIC} --port ${DB_PORT} --username ${DB_ROOT_ROLE} --dbname ${DB_ROOT_NAME} --no-password <<-EOSQL

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

ALTER USER ${META_DB_ROLE} SET search_path = public;
\q
EOSQL