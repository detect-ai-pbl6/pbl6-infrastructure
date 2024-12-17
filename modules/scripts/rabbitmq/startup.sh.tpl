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

sudo docker run --log-driver=gcplogs -d \
  -e RABBITMQ_DEFAULT_USER=${RABBITMQ_USERNAME} \
  -e RABBITMQ_DEFAULT_PASS=${RABBITMQ_PASSWORD} \
  -e RABBITMQ_DEFAULT_VHOST=${RABBITMQ_VHOST} \
  -p 5672:5672 -p 15672:15672 \
  rabbitmq:4.0-management
