#!/bin/bash
set -e

ENVIRONNMENT=dev

# load env vars
source .env.${ENVIRONNMENT}

# connect with SSL required
# role: root
export PGSSLMODE=require
export PGPASSWORD=${DB_ROOT_PASS}
psql --host ${DB_HOST} --port ${DB_PORT} --username ${DB_ROOT_ROLE} --dbname ${DB_ROOT_NAME} --no-password <<-EOSQL

\conninfo
\timing

CREATE ROLE airflow WITH
    LOGIN
    PASSWORD 'airflow'
    VALID UNTIL 'infinity'
    CONNECTION LIMIT 10;

CREATE DATABASE airflow WITH
    OWNER airflow
    ENCODING='UTF8'
    LC_COLLATE='en_US.UTF-8'
    LC_CTYPE='en_US.UTF-8'
    TEMPLATE template0;

GRANT ALL PRIVILEGES ON DATABASE airflow TO airflow;
GRANT ALL ON SCHEMA public TO airflow;

\q
EOSQL