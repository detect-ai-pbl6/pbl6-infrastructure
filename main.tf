module "services" {
  source               = "./modules"
  project_name         = var.project_name
  region               = var.region
  project_id           = var.project_id
  zone                 = var.zone
  db_name              = var.db_name
  db_password          = var.db_password
  db_tier              = var.db_tier
  db_user              = var.db_user
  secret_key           = var.secret_key
  cors_allowed_origins = var.cors_allowed_origins
  csrf_trusted_origins = var.csrf_trusted_origins
  domain_name          = var.domain_name
  private_key          = var.private_key
  public_key           = var.public_key
  gcp_client_id        = var.gcp_client_id
  gcp_secret           = var.gcp_secret
  superuser_email      = var.superuser_email
  superuser_password   = var.superuser_password
  admin_origin         = var.admin_origin

  rabbitmq_password = var.rabbitmq_password
  rabbitmq_username = var.rabbitmq_username
  rabbitmq_vhost    = var.rabbitmq_vhost

  github_client_id = var.github_client_id
  github_secret    = var.github_secret
}
