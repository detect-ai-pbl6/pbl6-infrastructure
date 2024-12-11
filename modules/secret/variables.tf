variable "database_host" {
  type        = string
  description = "database host"
}

variable "database_user" {
  type        = string
  description = "database user"
}

variable "database_name" {
  type        = string
  description = "database name"
}

variable "database_password" {
  type        = string
  description = "database password"
}

variable "project_name" {
  type        = string
  description = "project name"
}

variable "bucket_name" {
  type        = string
  description = "bucket name"
}

variable "secret_key" {
  type        = string
  description = "server secret key"
}

variable "cors_allowed_origins" {
  type        = string
  description = "server allow cors for origins"
}

variable "csrf_trusted_origins" {
  type        = string
  description = "server bypass csrf for origins"
}

variable "host" {
  type        = string
  description = "server host"
}

variable "private_key" {
  type        = string
  description = "private name"
}

variable "public_key" {
  type        = string
  description = "public name"
}

variable "gcp_client_id" {
  type        = string
  description = "gcp app client id"
}

variable "gcp_secret" {
  type        = string
  description = "gcp app secret"
}

variable "superuser_email" {
  type        = string
  description = "superuser email"
}


variable "superuser_password" {
  type        = string
  description = "superuser password"
}

variable "admin_origin" {
  type        = string
  description = "admin origin"
}


variable "rabbitmq_username" {
  type        = string
  description = "rabbitmq username"
}

variable "rabbitmq_password" {
  type        = string
  description = "rabbitmq password"
}

variable "rabbitmq_host" {
  type        = string
  description = "rabbitmq host"
}

variable "rabbitmq_vhost" {
  type        = string
  description = "rabbitmq vhost"
}
