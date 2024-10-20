locals {
  secret_name_prefix = "${var.project_name}-${terraform.workspace}-secrets"
}

resource "google_secret_manager_secret" "database_host" {
  secret_id = "${local.secret_name_prefix}-database-host"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "database_host_version" {
  secret      = google_secret_manager_secret.database_host.name
  secret_data = var.database_host
}


resource "google_secret_manager_secret" "database_user" {
  secret_id = "${local.secret_name_prefix}-database-user"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "database_user_version" {
  secret      = google_secret_manager_secret.database_user.name
  secret_data = var.database_user
}

resource "google_secret_manager_secret" "database_password" {
  secret_id = "${local.secret_name_prefix}-database-password"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "database_password_version" {
  secret      = google_secret_manager_secret.database_password.name
  secret_data = var.database_password
}

resource "google_secret_manager_secret" "database_name" {
  secret_id = "${local.secret_name_prefix}-database-name"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "database_name_version" {
  secret      = google_secret_manager_secret.database_name.name
  secret_data = var.database_name
}
