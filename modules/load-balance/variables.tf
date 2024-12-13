variable "project_id" {
  type        = string
  description = "The unique identifier for the project, typically used in cloud services to reference the project."
}

variable "project_name" {
  type        = string
  description = "The name of the project, used for organizational purposes and identification."
}

variable "domain_name" {
  type        = string
  description = "The fully qualified domain name (FQDN) for the project or service (e.g., 'example.com')."
}

variable "instance_group" {
  type        = string
  description = "The name of the instance group resource that will serve as the Load Balance backend."
}
