#!/bin/bash
set -e

# load env vars
source .env.psql

# connect with SSL required
# role: dbadmin
export PGSSLMODE=require
export PGPASSWORD=${DB_ADMIN_PASS}
psql --host ${DB_HOST_PUBLIC} --port ${DB_PORT} --dbname ${DB_NAME} --username ${DB_ADMIN_ROLE} --no-password

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
