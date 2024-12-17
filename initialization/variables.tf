variable "project_name" {
  type        = string
  description = "Name of the Google Cloud project being configured"
}

variable "project_number" {
  type        = string
  description = "Number of the Google Cloud project being configured"
}

variable "bucket_name" {
  type        = string
  description = "Name of the Google Cloud Storage bucket used for storing Terraform state files"
}

variable "project_id" {
  type        = string
  description = "Unique identifier of the Google Cloud project"
}

variable "region" {
  type        = string
  description = "Google Cloud region where resources will be deployed (e.g., us-central1, europe-west1)"
}

variable "zone" {
  type        = string
  description = "Specific Google Cloud zone within the selected region (e.g., us-central1-a, europe-west1-b)"
}
