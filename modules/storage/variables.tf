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

variable "allowed_cors_origins" {
  description = "List of allowed CORS origins"
  type        = list(string)
  default     = []
}

variable "cors_methods" {
  description = "Allowed HTTP methods for CORS"
  type        = list(string)
  default     = null
}

variable "cors_response_headers" {
  description = "Allowed response headers for CORS"
  type        = list(string)
  default     = null
}

variable "cors_max_age" {
  description = "Maximum age for CORS preflight request caching"
  type        = number
  default     = null
}

variable "versioning" {
  description = "Maximum age for CORS preflight request caching"
  type        = bool
  default     = false
}
