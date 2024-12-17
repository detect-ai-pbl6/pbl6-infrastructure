terraform {
  required_version = ">= 1.3.0"

  backend "gcs" {
    bucket = "pbl6-dev-tf-state-bucket-hxot"
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
