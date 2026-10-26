variable "infisical_host" {
  description = "Infisical API host. Leave null for Infisical Cloud."
  type        = string
  default     = null
}

variable "infisical_auth" {
  description = "Infisical authentication. Keep credentials in ignored local configuration or provider-supported environment variables."
  type = object({
    organization_slug = optional(string)
    token             = optional(string)
    aws_iam = optional(object({
      identity_id = optional(string)
    }))
    kubernetes = optional(object({
      identity_id                = optional(string)
      service_account_token      = optional(string)
      service_account_token_path = optional(string)
    }))
    oidc = optional(object({
      identity_id                     = optional(string)
      token_environment_variable_name = optional(string)
    }))
    universal = optional(object({
      client_id     = optional(string)
      client_secret = optional(string)
    }))
  })
  default   = null
  sensitive = true
}

variable "infisical_project_id" {
  description = "Infisical project ID, also called workspace_id by the provider."
  type        = string
  nullable    = false
}

variable "infisical_env_slug" {
  description = "Infisical environment containing the Arcane provider settings."
  type        = string
  default     = "prod"
}

variable "infisical_arcane_config_path" {
  description = "Infisical folder containing arcane_endpoint, arcane_api_key and optional Git credentials."
  type        = string
  default     = "/opentofu/arcane"
}
