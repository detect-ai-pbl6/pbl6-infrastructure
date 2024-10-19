module "services" {
  source       = "./modules"
  bucket_name  = var.bucket_name
  project_name = var.project_name
  region       = var.region
  project_id   = var.project_id
  zone         = var.zone
}
