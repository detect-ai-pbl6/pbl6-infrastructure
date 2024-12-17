#!/bin/bash

# Add Docker's official GPG key:
sudo apt-get update

# Install prerequisites
sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

# Add Docker's official GPG key

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up Docker repository
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

# Update package lists again
sudo apt-get update

# Install Docker Engine

sudo apt-get install -y docker-ce docker-ce-cli containerd.io

sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && sudo chmod +x /usr/bin/yq

gcloud auth configure-docker --quiet
gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet

gcloud storage cp gs://${BUCKET_NAME}/model.pth /etc/docker/
mkdir -p /etc/nginx
cat <<EOT >/etc/nginx/nginx.conf
${NGINX_CONTENT}
EOT

mkdir -p /etc/docker
cat <<EOT >/etc/docker/docker-compose.yml
${DOCKER_COMPOSE_CONTENT}
EOT

docker compose -f /etc/docker/docker-compose.yml up -d
