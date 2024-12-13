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

variable "db_tier" {
  type        = string
  description = "The machine type or tier for the database instance (e.g., db-f1-micro, db-custom-2-7680)"
}

variable "db_user" {
  type        = string
  description = "Username for accessing the database"
}

variable "db_name" {
  type        = string
  description = "Name of the database to be created"
}

variable "db_password" {
  type        = string
  description = "Password for the database user"
  sensitive   = true
}

variable "secret_key" {
  type        = string
  description = "A secret key used for server-side security and encryption"
  sensitive   = true
}

variable "cors_allowed_origins" {
  type        = string
  description = "Comma-separated list of origins allowed for Cross-Origin Resource Sharing (CORS)"
}

variable "csrf_trusted_origins" {
  type        = string
  description = "Comma-separated list of origins trusted to bypass Cross-Site Request Forgery (CSRF) protection"
}

variable "domain_name" {
  type        = string
  description = "Primary domain name for the application"
}

variable "private_key" {
  type        = string
  description = "Private key used for authentication or encryption"
  sensitive   = true
}

variable "public_key" {
  type        = string
  description = "Public key corresponding to the private key"
}

variable "gcp_client_id" {
  type        = string
  description = "Client ID for Google Cloud Platform OAuth authentication"
}

variable "gcp_secret" {
  type        = string
  description = "Client secret for Google Cloud Platform OAuth authentication"
  sensitive   = true
}

variable "superuser_email" {
  type        = string
  description = "Email address for the application's superuser account"
}

variable "superuser_password" {
  type        = string
  description = "Password for the superuser account"
  sensitive   = true
}

variable "admin_origin" {
  type        = string
  description = "Base URL or origin for the admin interface"
}

variable "rabbitmq_username" {
  type        = string
  description = "Username for accessing RabbitMQ message broker"
}

variable "rabbitmq_password" {
  type        = string
  description = "Password for the RabbitMQ user"
  sensitive   = true
}

variable "rabbitmq_vhost" {
  type        = string
  description = "Virtual host configuration for RabbitMQ"
}

variable "github_client_id" {
  type        = string
  description = "Client ID for Github OAuth authentication"
}

variable "github_secret" {
  type        = string
  description = "Client secret for Github OAuth authentication"
  sensitive   = true
}
