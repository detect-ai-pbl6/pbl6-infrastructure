variable "project_name" {
  type        = string
  description = "The name of the project, used for identification and organization."
}

variable "region" {
  type        = string
  description = "The geographical region where the resources will be deployed (e.g., 'us-east-1')."
}

variable "bucket_name" {
  type        = string
  description = "The name of the storage bucket, typically used in cloud storage services."
}

variable "allowed_cors_origins" {
  description = "A list of origins allowed to make CORS requests to the server (e.g., ['https://example.com'])."
  type        = list(string)
  default     = []
}

variable "cors_methods" {
  description = "A list of allowed HTTP methods for CORS (e.g., ['GET', 'POST', 'PUT'])."
  type        = list(string)
  default     = null
}

variable "cors_response_headers" {
  description = "A list of allowed response headers for CORS (e.g., ['Content-Type', 'Authorization'])."
  type        = list(string)
  default     = null
}

variable "cors_max_age" {
  description = "The maximum time in seconds that the results of a preflight request can be cached by the browser (e.g., 3600)."
  type        = number
  default     = null
}

variable "versioning" {
  description = "Enable or disable versioning for the storage bucket, allowing objects to have multiple versions (true or false)."
  type        = bool
  default     = false
}
