locals {
  ai_server = {
    docker_compose_conf_content = templatefile("${path.module}/scripts/ai-server/docker-compose.yml.tpl", {
      REGION              = var.region
      PROJECT_ID          = var.project_id
      ARTIFACT_REPOSITORY = module.ai_server_image_registry.artifact_name
      IMAGE_NAME          = "dev-ai-server"
      RABBITMQ_HOST       = module.rabbitmq_instance.instance_ip
      RABBITMQ_PASSWORD   = var.rabbitmq_password
      RABBITMQ_USERNAME   = var.rabbitmq_username
      RABBITMQ_VHOST      = var.rabbitmq_vhost
    })
    nginx_conf_content = filebase64("${path.module}/scripts/ai-server/nginx.conf.tpl")
  }
  api_server = {
    docker_compose_conf_content = templatefile("${path.module}/scripts/api-server/docker-compose.yml.tpl", {
      REGION              = var.region
      PROJECT_ID          = var.project_id
      ARTIFACT_REPOSITORY = module.backend_server_image_registry.artifact_name
      IMAGE_NAME          = "dev-backend-image"
    })
    nginx_conf_content = filebase64("${path.module}/scripts/api-server/nginx.conf.tpl")
  }
}