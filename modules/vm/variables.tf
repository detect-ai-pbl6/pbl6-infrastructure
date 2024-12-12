variable "instance_name" {
  type        = string
  description = "instance name"
}

variable "region" {
  type        = string
  description = "value"
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "zone" {
  type = string
}

variable "network" {
  type        = string
  description = "network name"
  default     = null
}

variable "sub_network" {
  type        = string
  description = "subnetwork name"
  default     = null
}
variable "is_spot" {
  type        = bool
  description = "spot instance"
  default     = false
}

variable "startup_script" {
  description = "Path to the startup script file"
  type        = any
  default     = null
}

variable "number_instances" {
  description = "Number of instances"
  type        = number
  default     = 1
}
variable "metadata" {
  description = "Instance metadata"
  type        = map(string)
  default     = {}
}

variable "network_id" {
  type        = string
  description = "network id"
}

variable "project_id" {
  type        = string
  description = "project id"
}

variable "force_recreate" {
  type        = bool
  description = "should re-create-instance"
  default     = false
}
