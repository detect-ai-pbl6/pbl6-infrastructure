resource "google_project_service" "cloud_kms" {
  project                    = var.project_id
  service                    = "cloudkms.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = true

}

resource "random_string" "random" {
  length  = 4
  special = false
  upper   = false
}
locals {
  cloud_storage_service_account = "service-${data.google_project.current.number}@gs-project-accounts.iam.gserviceaccount.com"
}

data "google_project" "current" {
  project_id = var.project_id
}

# KMS Key Ring
resource "google_kms_key_ring" "key_ring" {
  name     = "${var.project_name}-${terraform.workspace}-tfstate-key-ring-${random_string.random.result}"
  location = var.region

  depends_on = [google_project_service.cloud_kms]
}

resource "google_project_iam_binding" "project" {
  project = data.google_project.current.id
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members = [
    "serviceAccount:${local.cloud_storage_service_account}",
  ]
}
# KMS Crypto Key
resource "google_kms_crypto_key" "crypto_key" {
  name            = "${var.project_name}-${terraform.workspace}-tfstate-crypto-key"
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = "7776000s" # 90 days

  lifecycle {
    prevent_destroy = false
  }
  depends_on = [google_project_service.cloud_kms]
}

# Storage Bucket
resource "google_storage_bucket" "default" {
  name          = "${var.project_name}-${terraform.workspace}-${var.bucket_name}-${random_string.random.result}"
  force_destroy = true
  location      = var.region
  storage_class = "STANDARD"

  uniform_bucket_level_access = true # Enable uniform bucket-level access for better security

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = google_kms_crypto_key.crypto_key.id
  }

  # Add dependency to ensure KMS permissions are set before bucket creation
  depends_on = [google_project_iam_binding.project]
}

resource "local_file" "default" {
  file_permission = "0644"
  filename        = "${path.module}/../version.tf"

  # You can store the template in a file and use the templatefile function for
  # more modularity, if you prefer, instead of storing the template inline as
  # we do here.
  content = <<-EOT
  terraform {
    backend "gcs" {
      bucket = "${google_storage_bucket.default.name}"
      prefix = "tstatic.tfstate.d"
    }
    required_providers {
      google = {
        source  = "hashicorp/google"
        version = ">= 6.0, < 7"
      }
      google-beta = {
        source  = "hashicorp/google-beta"
        version = ">= 6.0, < 7"
      }
    }
  }
  EOT
}

resource "local_file" "variables_file" {
  file_permission = "0644"
  filename        = "${path.module}/../variables.tf"

  # You can store the template in a file and use the templatefile function for
  # more modularity, if you prefer, instead of storing the template inline as
  # we do here.
  content = <<-EOT
  variable "project_name" {
    type        = string
    description = "The name of the Google Cloud Platform (GCP) project"
  }

  variable "project_id" {
    type        = string
    description = "The unique identifier for the GCP project"
  }

  variable "region" {
    type        = string
    description = "The GCP region where resources will be deployed (e.g., us-central1, europe-west1)"
  }

  variable "zone" {
    type        = string
    description = "The specific zone within the selected region for resource placement"
  }
  EOT
}
# TODO: oidc set up


# TODO: domain set up
