resource "google_storage_bucket" "media_storage" {
  name                     = "${var.project_name}-${terraform.workspace}-${var.bucket_name}"
  force_destroy            = true
  location                 = var.region
  storage_class            = "STANDARD"
  public_access_prevention = length(var.allowed_cors_origins) > 0 ? "inherited" : "enforced"

  dynamic "cors" {
    for_each = length(var.allowed_cors_origins) > 0 ? [1] : []
    content {
      origin = var.allowed_cors_origins

      method = coalesce(var.cors_methods, ["GET", "HEAD", "PUT", "OPTIONS"])

      response_header = coalesce(var.cors_response_headers, ["*"])

      max_age_seconds = coalesce(var.cors_max_age, 3600)
    }
  }
  versioning {
    enabled = var.versioning
  }
}

resource "google_storage_bucket_iam_member" "member" {
  count  = length(var.allowed_cors_origins) > 0 ? 1 : 0
  bucket = google_storage_bucket.media_storage.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

