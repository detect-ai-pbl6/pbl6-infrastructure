resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}
resource "google_storage_bucket" "media_storage" {
  name                     = "${var.project_name}-${terraform.workspace}-${var.bucket_name}"
  force_destroy            = true
  location                 = var.region
  storage_class            = "STANDARD"
  public_access_prevention = "inherited"
}

resource "google_storage_bucket_iam_member" "member" {
  bucket = google_storage_bucket.media_storage.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_service_account" "storage_account" {
  account_id   = "${var.project_name}-${terraform.workspace}-sa-id-${random_string.random.result}"
  display_name = "${var.project_name}-${terraform.workspace}-sa-${random_string.random.result}"
  description  = "Service Account with full storage access"
}

# Grant storage roles
resource "google_project_iam_member" "storage_roles" {
  for_each = toset([
    "roles/storage.admin",
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.storage_account.email}"
}
