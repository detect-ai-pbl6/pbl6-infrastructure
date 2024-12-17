variable "instance_name" {
  type        = string
  description = "Name of the compute instance or instance group"
  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]*[a-z0-9])?$", var.instance_name))
    error_message = "Instance name must start with a lowercase letter, contain only lowercase letters, numbers, and hyphens, and end with a letter or number."
  }
}

variable "region" {
  type        = string
  description = "The GCP region where resources will be created"
  validation {
    condition     = can(regex("^[a-z]+-[a-z0-9]+$", var.region))
    error_message = "Region must be a valid GCP region format (e.g., us-central1, europe-west1)."
  }
}

variable "tags" {
  type        = list(string)
  default     = []
  description = "A list of network tags to apply to the instance"
  validation {
    condition     = alltrue([for tag in var.tags : can(regex("^[a-z0-9-]{1,64}$", tag))])
    error_message = "Each tag must be 1-64 characters, containing only lowercase letters, numbers, and hyphens."
  }
}

variable "zone" {
  type        = string
  description = "The specific zone within the region where the instance will be created"
  validation {
    condition     = can(regex("^[a-z]+-[a-z0-9]+-[a-z]$", var.zone))
    error_message = "Zone must be a valid GCP zone format (e.g., us-central1-a, europe-west1-b)."
  }
}

variable "network" {
  type        = string
  description = "The name of the VPC network"
  default     = "default"
  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]*[a-z0-9])?$", var.network))
    error_message = "Network name must start with a lowercase letter, contain only lowercase letters, numbers, and hyphens, and end with a letter or number."
  }
}

variable "sub_network" {
  type        = string
  description = "The name of the subnet within the VPC network"
  default     = null
}

variable "is_spot" {
  type        = bool
  description = "Whether to create a preemptible (spot) instance"
  default     = false
  validation {
    condition     = can(var.is_spot == true || var.is_spot == false)
    error_message = "is_spot must be a boolean value (true or false)."
  }
}

variable "startup_script" {
  type        = string
  description = "Path to the startup script file or the script content itself"
  default     = null
}

variable "instance_count" {
  type        = number
  description = "Number of instances to create"
  default     = 1
  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

variable "metadata" {
  type        = map(string)
  description = "A map of metadata key/value pairs to assign to the instances"
  default     = {}
  validation {
    condition     = alltrue([for k, v in var.metadata : can(regex("^[a-zA-Z][a-zA-Z0-9-_]*$", k))])
    error_message = "Metadata keys must start with a letter and contain only letters, numbers, underscores, and hyphens."
  }
}

variable "network_id" {
  type        = string
  description = "The full resource identifier for the network"
  validation {
    condition     = can(regex("^projects/[a-z0-9-]+/global/networks/[a-z0-9-]+$", var.network_id))
    error_message = "Network ID must be in the format: projects/{project}/global/networks/{network-name}."
  }
}

variable "project_id" {
  type        = string
  description = "The GCP project ID where resources will be created"
  validation {
    condition     = can(regex("^[a-z0-9-]{6,30}$", var.project_id))
    error_message = "Project ID must be 6-30 characters long, containing only lowercase letters, numbers, and hyphens."
  }
}

variable "force_recreate" {
  type        = bool
  description = "Force recreation of resources even if configuration hasn't changed"
  default     = false
  validation {
    condition     = can(var.force_recreate == true || var.force_recreate == false)
    error_message = "force_recreate must be a boolean value (true or false)."
  }
}

variable "machine_type" {
  type        = string
  description = "The machine type for the instances"
  default     = "e2-micro"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.machine_type))
    error_message = "Machine type must be a valid GCP machine type."
  }
}

variable "boot_disk_image" {
  type        = string
  description = "The source image for the boot disk"
  default     = "debian-cloud/debian-11"
  validation {
    condition     = can(regex("^[a-z0-9-]+/[a-z0-9-]+$", var.boot_disk_image))
    error_message = "Boot disk image must be in the format: 'project/image-name'."
  }
}
variable "instance_creation_mode" {
  description = "Mode of instance creation: 'single', 'managed_group', or 'mixed'"
  type        = string
  default     = "single"
  validation {
    condition     = contains(["single", "managed_group", "mixed"], var.instance_creation_mode)
    error_message = "Must be one of: 'single', 'managed_group', 'mixed'."
  }
}

variable "max_instances" {
  description = "Maximum number of instances for managed group"
  type        = number
  default     = 5
}

variable "min_instances" {
  description = "Minimum number of instances for managed group"
  type        = number
  default     = 1
}

variable "replace_trigger_by" {
  description = "Set of references to any other resources which when changed cause this resource to be proposed for replacement"
  type        = any
  default     = ""
}


variable "health_check_request_path" {
  description = "Set of references to any other resources which when changed cause this resource to be proposed for replacement"
  type        = string
  default     = "/api/health"
}
