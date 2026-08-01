#!/bin/bash
set -e

ENVIRONNMENT=dev

# load env vars
source .env.${ENVIRONNMENT}

# connect with SSL required
# role: root
export PGSSLMODE=require
export PGPASSWORD=${DB_ROOT_PASS}
psql --host ${DB_HOST} --port ${DB_PORT} --dbname ${DB_ROOT_NAME} --username ${DB_ROOT_ROLE} --no-password <<-EOSQL

\timing

-- terminate all active connections to db
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='${DB_NAME}';

DROP DATABASE IF EXISTS ${DB_NAME};

DROP ROLE IF EXISTS ${DB_READ_ROLE};

DROP ROLE IF EXISTS ${DB_ADMIN_ROLE};

\q
EOSQL