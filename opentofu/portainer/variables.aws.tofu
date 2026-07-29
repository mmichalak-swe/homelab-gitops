variable "aws_region" {
  description = "AWS region containing the S3 bucket used for OpenTofu state."
  type        = string
}

variable "state_bucket_name" {
  description = "Globally unique name of the S3 bucket used for OpenTofu state."
  type        = string
}

variable "state_bucket_tags" {
  description = "Additional tags to apply to the OpenTofu state bucket."
  type        = map(string)
  default     = {}
}
