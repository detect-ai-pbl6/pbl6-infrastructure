version: '3.9'

services:
  backend-service:
    image: ${REGION}-docker.pkg.dev/${PROJECT_ID}/${ARTIFACT_REPOSITORY}/${IMAGE_NAME}:latest
    restart: unless-stopped
    env_file: /etc/docker/.env
    logging:
      driver: gcplogs
      
  nginx-proxy:
    image: nginx:latest
    container_name: nginx-proxy
    restart: unless-stopped
    volumes:
      - /etc/nginx/nginx.conf:/etc/nginx/nginx.conf:ro
    ports:
      - "80:80"
    logging:
      driver: gcplogs