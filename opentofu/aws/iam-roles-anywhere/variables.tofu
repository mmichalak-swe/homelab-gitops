variable "aws_region" {
  description = "AWS region in which to create the regional IAM Roles Anywhere resources. If null, use the AWS provider's normal region resolution."
  type        = string
  default     = null
  nullable    = true
}

variable "name_prefix" {
  description = "Prefix used for the trust anchor, IAM role, profile, and inline policy names."
  type        = string
  default     = "homelab"

  validation {
    condition     = can(regex("^[A-Za-z0-9_-]+$", var.name_prefix))
    error_message = "name_prefix may contain only letters, numbers, underscores, and hyphens."
  }
}

variable "ca_private_key_pem" {
  description = "Unencrypted PEM private key used to sign the root CA certificate. Keep this only in an ignored local tfvars file and a protected backup."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("-----BEGIN (RSA |EC )?PRIVATE KEY-----", var.ca_private_key_pem))
    error_message = "ca_private_key_pem must contain an unencrypted PEM private key."
  }
}

variable "ca_common_name" {
  description = "Common name placed in the root CA certificate and required as the x509Issuer/CN session tag."
  type        = string
  default     = "Homelab IAM Roles Anywhere Root CA"

  validation {
    condition     = length(trimspace(var.ca_common_name)) > 0 && length(var.ca_common_name) <= 64
    error_message = "ca_common_name must contain between 1 and 64 characters."
  }
}

variable "ca_organization" {
  description = "Organization placed in the root CA certificate subject."
  type        = string
  default     = "Homelab"
}

variable "ca_validity_period_hours" {
  description = "Root CA certificate lifetime in hours. The default is approximately ten years."
  type        = number
  default     = 87600

  validation {
    condition     = var.ca_validity_period_hours >= 8760
    error_message = "ca_validity_period_hours must be at least one year (8760 hours)."
  }
}

variable "profile_duration_seconds" {
  description = "Lifetime of credentials vended by the IAM Roles Anywhere profile."
  type        = number
  default     = 3600

  validation {
    condition     = var.profile_duration_seconds >= 900 && var.profile_duration_seconds <= 43200
    error_message = "profile_duration_seconds must be between 900 and 43200 seconds."
  }
}

variable "roles" {
  description = "IAM roles exposed through Roles Anywhere, including certificate CN authorization and permission policies."
  type = map(object({
    description                  = optional(string)
    allowed_subject_common_names = set(string)
    max_session_duration         = optional(number, 3600)
    managed_policy_arns          = optional(set(string), [])
    inline_policy_json           = optional(string)
    permissions_boundary_arn     = optional(string)
    profile_managed_policy_arns  = optional(set(string), [])
    profile_session_policy_json  = optional(string)
  }))

  default = {
    s3-service-user = {
      description                  = "S3 access for approved homelab workloads through IAM Roles Anywhere"
      allowed_subject_common_names = ["s3-service-user"]
    }

    terraform-service-user = {
      description                  = "OpenTofu access for approved homelab workloads through IAM Roles Anywhere"
      allowed_subject_common_names = ["terraform-service-user"]
    }
  }

  validation {
    condition     = length(var.roles) > 0 && alltrue([for name, role in var.roles : can(regex("^[A-Za-z0-9_+=,.@-]{1,64}$", name))])
    error_message = "roles must contain at least one valid IAM role name."
  }

  validation {
    condition = alltrue([
      for role in values(var.roles) :
      length(role.allowed_subject_common_names) > 0 && alltrue([
        for value in role.allowed_subject_common_names :
        length(trimspace(value)) > 0 && length(value) <= 61
      ])
    ])
    error_message = "Each role must allow at least one non-empty certificate common name of no more than 61 characters."
  }

  validation {
    condition     = alltrue([for role in values(var.roles) : role.max_session_duration >= 3600 && role.max_session_duration <= 43200])
    error_message = "Each max_session_duration must be between 3600 and 43200 seconds."
  }

  validation {
    condition     = alltrue([for role in values(var.roles) : role.inline_policy_json == null ? true : can(jsondecode(role.inline_policy_json))])
    error_message = "Each inline_policy_json must be valid JSON when set."
  }

  validation {
    condition     = alltrue([for role in values(var.roles) : role.profile_session_policy_json == null ? true : can(jsondecode(role.profile_session_policy_json))])
    error_message = "Each profile_session_policy_json must be valid JSON when set."
  }
}

variable "tags" {
  description = "Additional tags applied to supported resources."
  type        = map(string)
  default = {
    Purpose = "IAM Roles Anywhere for homelab workloads"
  }
}

check "profile_duration_fits_role" {
  assert {
    condition     = alltrue([for role in values(var.roles) : var.profile_duration_seconds <= role.max_session_duration])
    error_message = "profile_duration_seconds must not exceed any role's max_session_duration."
  }
}
