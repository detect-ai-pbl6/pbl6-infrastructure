terraform {
  required_version = ">=0.12"
  backend "gcs" {
    bucket = "test-tf-state-bucket-minhngoc"
    # impersonate_service_account = "test-service-account@engaged-reducer-436815-p9.iam.gserviceaccount.com"
    prefix = "tstatic.tfstate.d"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.26"
    }
  }
}
