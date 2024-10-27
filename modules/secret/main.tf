locals {
  secret_name_prefix = "${var.project_name}-${terraform.workspace}-secrets"
  secrets = {
    "db-host"              = var.database_host
    "db-username"          = var.database_user
    "db-password"          = var.database_password
    "db-name"              = var.database_name
    "gcp-bucket-name"      = var.bucket_name
    "host"                 = var.host
    "secret-key"           = var.secret_key
    "cors-allowed-origins" = var.cors_allowed_origins
    "private-key"          = var.private_key
    "public-key"           = var.public_key
  }
}

# Create secrets and their versions in a loop
resource "google_secret_manager_secret" "secrets" {
  for_each  = local.secrets
  secret_id = "${local.secret_name_prefix}-${each.key}"
  replication {
    auto {}
  }
  lifecycle {
    create_before_destroy = false
  }
}

resource "google_secret_manager_secret_version" "secrets_version" {
  for_each    = local.secrets
  secret      = google_secret_manager_secret.secrets[each.key].name
  secret_data = each.value

  lifecycle {
    create_before_destroy = false
  }
}
