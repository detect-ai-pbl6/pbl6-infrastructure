#!/bin/sh
# Update system packages
sudo apt update -y && sudo apt upgrade -y

# Install PostgreSQL server and development packages
apt install postgresql-16 postgresql-16-contrib -y

# Initialize the database cluster for PostgreSQL
sudo -u postgres pg_createcluster --start 16 main

# Backup PostgreSQL authentication config file
sudo mv /etc/postgresql/16/main/pg_hba.conf /etc/postgresql/16/main/pg_hba.conf.bak

# Create our new PostgreSQL authentication config file
sudo cat <<'EOF' >/etc/postgresql/16/main/pg_hba.conf
${pg_hba_file}
EOF

# Update the IPs of the address to listen from PostgreSQL config
sudo echo "listen_addresses = '*'" >>/etc/postgresql/16/main/postgresql.conf

# Start the db service
sudo systemctl enable postgresql
sudo systemctl start postgresql
