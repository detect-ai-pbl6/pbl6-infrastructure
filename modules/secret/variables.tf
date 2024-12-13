variable "database_host" {
  type        = string
  description = "The hostname or IP address of the database server."
}

variable "database_user" {
  type        = string
  description = "The username used to connect to the database."
}

variable "database_name" {
  type        = string
  description = "The name of the database to connect to."
}

variable "database_password" {
  type        = string
  description = "The password for the database user account."
}

variable "project_name" {
  type        = string
  description = "The name of the project, used for identification purposes."
}

variable "bucket_name" {
  type        = string
  description = "The name of the storage bucket (e.g., for cloud storage)."
}

variable "secret_key" {
  type        = string
  description = "A secret key used for server-side cryptographic operations."
}

variable "cors_allowed_origins" {
  type        = string
  description = "A list of origins allowed to make CORS requests to the server."
}

variable "csrf_trusted_origins" {
  type        = string
  description = "A list of origins trusted for bypassing CSRF protection on the server."
}

variable "host" {
  type        = string
  description = "The host address or domain for the server."
}

variable "private_key" {
  type        = string
  description = "The private key used for signing or encryption operations."
}

variable "public_key" {
  type        = string
  description = "The public key corresponding to the private key for verification or decryption operations."
}

variable "gcp_client_id" {
  type        = string
  description = "The client ID for authenticating GCP (Google Cloud Platform) applications."
}

variable "gcp_secret" {
  type        = string
  description = "The client secret for authenticating GCP (Google Cloud Platform) applications."
}

variable "superuser_email" {
  type        = string
  description = "The email address for the superuser account."
}

variable "superuser_password" {
  type        = string
  description = "The password for the superuser account."
}

variable "admin_origin" {
  type        = string
  description = "The origin allowed to access the admin panel or functionality."
}

variable "rabbitmq_username" {
  type        = string
  description = "The username used to authenticate with RabbitMQ."
}

variable "rabbitmq_password" {
  type        = string
  description = "The password associated with the RabbitMQ username."
}

variable "rabbitmq_host" {
  type        = string
  description = "The hostname or IP address of the RabbitMQ server."
}

variable "rabbitmq_vhost" {
  type        = string
  description = "The virtual host within RabbitMQ that the application will use."
}

variable "github_client_id" {
  type        = string
  description = "The client ID for OAuth authentication with GitHub."
}

variable "github_secret" {
  type        = string
  description = "The client secret for OAuth authentication with GitHub."
  sensitive   = true
}
