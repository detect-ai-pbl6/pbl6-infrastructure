resource "google_kms_key_ring" "key_ring" {
  name     = "${var.project_name}-${terraform.workspace}-tfstate-key-ring"
  location = var.region
}

resource "google_kms_crypto_key" "crypto_key" {
  name     = "${var.project_name}-${terraform.workspace}-tfstate-crypto-key"
  key_ring = google_kms_key_ring.key_ring.id
}


resource "google_storage_bucket" "default" {
  name          = "${var.project_name}-${terraform.workspace}-${var.bucket_name}"
  force_destroy = true
  location      = var.region
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
  encryption {
    default_kms_key_name = google_kms_crypto_key.crypto_key.id
  }
}
