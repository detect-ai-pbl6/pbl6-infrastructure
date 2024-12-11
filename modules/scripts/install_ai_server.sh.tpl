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

gcloud auth configure-docker --quiet
gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet
docker pull ${REGION}-docker.pkg.dev/${PROJECT_ID}/${ARTIFACT_REPOSITORY}/${IMAGE_NAME}:latest
docker run --rm -d -p 8080:80 -e MESSAGE_BROKER_HOST=${RABBITMQ_HOST} \
  -e MESSAGE_BROKER_PASSWORD=${RABBITMQ_PASSWORD} \
  -e MESSAGE_BROKER_USERNAME=${RABBITMQ_USERNAME} \
  -e MESSAGE_BROKER_VHOST=${RABBITMQ_VHOST} \
  ${REGION}-docker.pkg.dev/${PROJECT_ID}/${ARTIFACT_REPOSITORY}/${IMAGE_NAME}:latest
