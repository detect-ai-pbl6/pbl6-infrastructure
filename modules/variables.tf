variable "project_name" {
  type        = string
  description = "The name of the project. Used for identification purposes in resources and configurations."
}

variable "region" {
  type        = string
  description = "The GCP region where the resources will be deployed."
}

variable "project_id" {
  type        = string
  description = "The ID of the GCP project where the resources will be created."
}

variable "zone" {
  type        = string
  description = "The specific zone within the selected GCP region for resource deployment."
}

variable "db_tier" {
  type        = string
  description = "The tier of the database instance (e.g., db-f1-micro, db-n1-standard-1)."
}

variable "db_user" {
  type        = string
  description = "The username for accessing the database."
}

variable "db_name" {
  type        = string
  description = "The name of the database to be created or used."
}

variable "db_password" {
  type        = string
  description = "The password associated with the database user."
}

variable "secret_key" {
  type        = string
  description = "A secret key used for server-side cryptographic operations."
}

variable "cors_allowed_origins" {
  type        = string
  description = "Comma-separated list of origins allowed for Cross-Origin Resource Sharing (CORS)."
}

variable "csrf_trusted_origins" {
  type        = string
  description = "Comma-separated list of origins trusted to bypass CSRF protection."
}

variable "domain_name" {
  type        = string
  description = "The domain name where the application will be hosted."
}

variable "private_key" {
  type        = string
  description = "The private key used for secure communication or encryption."
}

variable "public_key" {
  type        = string
  description = "The public key used for secure communication or encryption."
}

variable "gcp_client_id" {
  type        = string
  description = "The client ID of the GCP OAuth application."
}

variable "gcp_secret" {
  type        = string
  description = "The secret key of the GCP OAuth application."
}

variable "superuser_email" {
  type        = string
  description = "The email address of the superuser account."
}

variable "superuser_password" {
  type        = string
  description = "The password for the superuser account."
}

variable "admin_origin" {
  type        = string
  description = "The origin URL for the admin interface."
}

variable "rabbitmq_username" {
  type        = string
  description = "The username for RabbitMQ authentication."
}

variable "rabbitmq_password" {
  type        = string
  description = "The password for RabbitMQ authentication."
}

variable "rabbitmq_vhost" {
  type        = string
  description = "The RabbitMQ virtual host to be used for organizing queues and exchanges."
}
