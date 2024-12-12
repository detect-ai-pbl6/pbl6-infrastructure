variable "project_name" {
  type        = string
  description = "project name"
}

variable "region" {
  type        = string
  description = "value"
}

variable "project_id" {
  type        = string
  description = "project id"
}

variable "network_id" {
  type        = string
  description = "vpc network id"
}

variable "envs_data" {
  type        = any
  description = "enviroments pass to container "
}

variable "cloud_sql_connection_name" {
  type        = string
  description = "cloud sql instance name"
}
