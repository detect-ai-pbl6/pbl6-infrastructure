module "services" {
  source       = "./modules"
  bucket_name  = var.bucket_name
  project_name = var.project_name
  region       = var.region
  project_id   = var.project_id
  zone         = var.zone
  db_name      = var.db_name
  db_password  = var.db_password
  db_tier      = var.db_tier
  db_user      = var.db_user
  secret_key   = var.secret_key
}
