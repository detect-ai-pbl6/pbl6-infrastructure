variable "project_name" {
  type        = string
  description = "The name of the project, used for identification and organization."
}

variable "region" {
  type        = string
  description = "The geographical region where the resources will be deployed (e.g., 'us-east-1')."
}

variable "project_id" {
  type        = string
  description = "The GCP project ID where resources will be created"
}
