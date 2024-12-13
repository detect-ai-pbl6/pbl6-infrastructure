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
# Install Docker Rollout
# Create directory for Docker cli plugins
sudo mkdir -p /usr/local/lib/docker/cli-plugins

# Download docker-rollout script to system-wide Docker cli plugins directory
sudo curl https://raw.githubusercontent.com/wowu/docker-rollout/master/docker-rollout -o /usr/local/lib/docker/cli-plugins/docker-rollout

# Make the script executable for all users
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-rollout

gcloud auth configure-docker --quiet
gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet

mkdir -p /etc/nginx
cat <<EOT >/etc/nginx/nginx.conf
${NGINX_CONTENT}
EOT

mkdir -p /etc/docker
cat <<EOT >/etc/docker/docker-compose.yml
${DOCKER_COMPOSE_CONTENT}
EOT

# Output file
OUTPUT_FILE="/etc/docker/.env"

# Define the prefix to remove
PREFIX_TO_REMOVE="${PROJECT_NAME}-${ENVIROMENT}-secrets-"

# Clear or create the output file
: >"$OUTPUT_FILE"

# Get a list of all secret names
SECRET_NAMES=$(gcloud secrets list --format="value(name)")

if [ -z "$SECRET_NAMES" ]; then
  echo "No secrets found in the current project."
  exit 0
fi

# Loop through each secret name and fetch its latest value
for SECRET_NAME in $SECRET_NAMES; do
  echo "Fetching secret: $SECRET_NAME"

  # Get the latest value of the secret
  LATEST_SECRET_VALUE=$(gcloud secrets versions access latest --secret="$SECRET_NAME" 2>/dev/null)

  if [ $? -ne 0 ]; then
    echo "Error: Failed to retrieve the value for $SECRET_NAME"
    LATEST_SECRET_VALUE=""
  fi

  # Remove the prefix if it exists
  SANITIZED_KEY="$${SECRET_NAME}"
  if [[ $SANITIZED_KEY == $${PREFIX_TO_REMOVE}* ]]; then
    SANITIZED_KEY=$${SANITIZED_KEY#"$PREFIX_TO_REMOVE"}
  fi

  # Convert to uppercase and replace '-' with '_'
  SANITIZED_KEY=$(echo "$SANITIZED_KEY" | sed 's/-/_/g; s/[a-z]/\U&/g')
  # Append to .env file
  echo "$${SANITIZED_KEY}=\"$${LATEST_SECRET_VALUE}\"" >>"$OUTPUT_FILE"
done

echo ".env file created successfully at: $OUTPUT_FILE"

docker compose -f /etc/docker/docker-compose.yml up -d
