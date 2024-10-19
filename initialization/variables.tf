variable "project_name" {
  type    = string
  default = "pbl6"
}
variable "bucket_name" {
  default = "tf-state-bucket"
}

variable "project_id" {
  type        = string
  description = "project id"
  default     = "pbl6-439109"
}

variable "region" {
  type        = string
  description = "value"
  default     = "asia-southeast1"
}
variable "zone" {
  type    = string
  default = "asia-southeast1-a"
}
