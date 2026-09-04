variable "aws_region" {
  description = "AWS region containing the OpenTofu state bucket."
  type        = string
}

variable "state_bucket_name" {
  description = "Globally unique name of the existing S3 bucket used for OpenTofu state."
  type        = string
}

variable "state_bucket_tags" {
  description = "Additional tags to apply to the OpenTofu state bucket."
  type        = map(string)
  default     = {}
}

variable "noncurrent_versions_to_retain" {
  description = "Number of newer noncurrent versions to retain before expiration can occur."
  type        = number
  default     = 10

  validation {
    condition     = var.noncurrent_versions_to_retain >= 5
    error_message = "Retain at least five noncurrent state versions."
  }
}

variable "noncurrent_version_expiration_days" {
  description = "Minimum age in days before excess noncurrent state versions can expire."
  type        = number
  default     = 30

  validation {
    condition     = var.noncurrent_version_expiration_days >= 7
    error_message = "Retain excess noncurrent state versions for at least seven days."
  }
}
