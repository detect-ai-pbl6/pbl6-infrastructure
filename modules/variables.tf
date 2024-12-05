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

variable "cors_allowed_origins" {
  type        = string
  description = "server allow cors for origins"
}

variable "csrf_trusted_origins" {
  type        = string
  description = "server bypass csrf for origins"
}

variable "domain_name" {
  type        = string
  description = "domain name"
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
