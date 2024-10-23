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

variable "host" {
  type        = string
  description = "server host"
}
