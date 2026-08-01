#!/bin/bash
# installation psql a client for PostgreSQL
set -e

POSTGRESQL_VERSION=18

# verify if installed
#####################
if command -v psql >&2; then
  echo Stop installation, psql is installed: $(psql --version)
  exit 1
else
  echo "Start installation psql (${POSTGRESQL_VERSION})"
fi

# Update System Packages
########################
# Update the package list and upgrade existing packages
sudo apt update && sudo apt upgrade -y

# Install psql
##############
# Install required dependencies for adding repositories
sudo apt install -y wget gnupg2 lsb-release
# Add the official PostgreSQL repository GPG key
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /usr/share/keyrings/postgresql-archive-keyring.gpg
# Add the PostgreSQL repository to your sources list
echo "deb [signed-by=/usr/share/keyrings/postgresql-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
# Update package list with the new repository
sudo apt update
# Install PostgreSQL
sudo apt install -y "postgresql-client-${POSTGRESQL_VERSION}" #postgresql-contrib-18

# Test
######
psql --version