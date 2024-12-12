version: '3.9'

services:
  ai-service:
    image: ${REGION}-docker.pkg.dev/${PROJECT_ID}/${ARTIFACT_REPOSITORY}/${IMAGE_NAME}:latest
    restart: unless-stopped
    environment:
      - MESSAGE_BROKER_HOST=${RABBITMQ_HOST}
      - MESSAGE_BROKER_PASSWORD=${RABBITMQ_PASSWORD}
      - MESSAGE_BROKER_USERNAME=${RABBITMQ_USERNAME}
      - MESSAGE_BROKER_VHOST=${RABBITMQ_VHOST}
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