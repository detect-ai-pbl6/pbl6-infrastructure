#!/bin/bash

# Update package lists
sudo apt update -y
sudo apt install -y postgresql-common
sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -i -v 16

# Install necessary prerequisites
# sudo apt install curl ca-certificates
# sudo install -d /usr/share/postgresql-common/pgdg
# sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
# sudo sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
# sudo apt update -y
# sudo apt -y install postgresql

# Enable and start PostgreSQL 16 service
sudo systemctl enable postgresql
sudo systemctl start postgresql
sudo sed -i "s/^local[[:space:]]\+all[[:space:]]\+postgres[[:space:]]\+peer/local   all   postgres   trust/" /etc/postgresql/16/main/pg_hba.conf

sudo systemctl restart postgresql

# Variables
DB_USER="${DB_USER:-default_user}"             # Default to 'default_user' if not set
DB_PASSWORD="${DB_PASSWORD:-default_password}" # Default to 'default_password' if not set
DB_NAME="${DB_NAME:-default_db}"

# Create a new PostgreSQL user and database
sudo -i -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';"
sudo -i -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"
sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"

# Optional: Allow remote connections
echo "host all all 0.0.0.0/0 md5" | sudo tee -a /etc/postgresql/16/main/pg_hba.conf

# # Adjust PostgreSQL to listen on all addresses
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/16/main/postgresql.conf

# Restart PostgreSQL service to apply changes
sudo systemctl restart postgresql

echo "PostgreSQL 16 setup completed."

# Add Docker's official GPG key:
# sudo apt-get update
# curl -fsSL https://get.docker.com -o get-docker.sh
# sh get-docker.sh

# # Variables
# DB_USER="${DB_USER:-default_user}"             # Default to 'default_user' if not set
# DB_PASSWORD="${DB_PASSWORD:-default_password}" # Default to 'default_password' if not set
# DB_NAME="${DB_NAME:-default_db}"

# # Run PostgreSQL container
# sudo docker run \
#   -e POSTGRES_USER=$DB_USER \
#   -e POSTGRES_PASSWORD=$DB_PASSWORD \
#   -e POSTGRES_DB=$DB_NAME \
#   -p 5432:5432 \
#   -d postgres:16

# # Create a new PostgreSQL user and database using psql
# # Using Docker exec to interact with the running container
# sudo docker exec -it $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"

# # Optional: Allow remote connections
# # This can be done by modifying the pg_hba.conf inside the container
# sudo docker exec -it $CONTAINER_NAME bash -c "echo 'host all all 0.0.0.0/0 md5' >> /var/lib/postgresql/data/pg_hba.conf"

# # Restart the container to apply changes
# sudo docker restart $CONTAINER_NAME

# echo "PostgreSQL 16 setup in Docker completed."
