terraform {
  required_version = ">=0.12"
  backend "gcs" {
    bucket = "pbl6-dev-tf-state-bucket"
    prefix = "tstatic.tfstate.d"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.26"
    }
  }
}
