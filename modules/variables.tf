variable "project_name" {
  type        = string
  description = "project name"
}

variable "region" {
  type        = string
  description = "value"
}

variable "bucket_name" {
  type = string
}

variable "project_id" {
  type        = string
  description = "project id"
}

variable "zone" {
  type = string
}

variable "db_tier" {
  type        = string
  description = "db tier"
}
variable "db_user" {
  type        = string
  description = "database user"
}
variable "db_name" {
  type        = string
  description = "database name"
}

variable "db_password" {
  type        = string
  description = "database password"
}

variable "secret_key" {
  type        = string
  description = "server secret key"
}

variable "service_account_roles" {
  description = "List of roles to assign to the service account"
  type        = list(string)
  default = [
    "roles/run.admin",                      # Ability to manage Cloud Run services
    "roles/iam.serviceAccountUser",         # Ability to run operations as the service account
    "roles/iam.serviceAccountTokenCreator", # Ability to run operations as the service account
    "roles/artifactregistry.writer",        # Ability to push container images

    # Optional roles based on your needs
    "roles/storage.objectViewer", # If you need to read from GCS
    "roles/storage.objectAdmin",
    "roles/storage.admin",
    "roles/logging.logWriter" # Write application logs
  ]
}

variable "github_repo" {
  description = "GitHub repository in format: OWNER/REPOSITORY"
  type        = string
  default     = "detect-ai-pbl6/pbl6-infrastructure"
}
