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
