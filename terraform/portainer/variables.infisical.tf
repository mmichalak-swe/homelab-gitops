variable "infisical_host" {
  description = "Infisical API host. Leave null to use the provider default, https://app.infisical.com."
  type        = string
  default     = null
}

variable "infisical_auth" {
  description = "Infisical provider auth object. Keep this in an ignored local.auto.tfvars file for local runs."
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
  default     = null
}

variable "infisical_env_slug" {
  description = "Infisical environment slug to read secrets from."
  type        = string
  default     = "prod"
}

variable "infisical_portainer_config_enabled" {
  description = "Fetch Portainer provider settings from Infisical."
  type        = bool
  default     = false
}

variable "infisical_portainer_config_env_slug" {
  description = "Infisical environment slug for Portainer provider settings. Defaults to infisical_env_slug."
  type        = string
  default     = null
}

variable "infisical_portainer_config_path" {
  description = "Infisical folder path for Portainer provider settings."
  type        = string
  default     = "/terraform/portainer"
}

variable "infisical_dockerhub_registry_tokens_enabled" {
  description = "Fetch Docker Hub registry tokens from Infisical."
  type        = bool
  default     = false
}

variable "infisical_dockerhub_registry_tokens_env_slug" {
  description = "Infisical environment slug for Docker Hub registry tokens. Defaults to infisical_env_slug."
  type        = string
  default     = null
}

variable "infisical_dockerhub_registry_tokens_path" {
  description = "Infisical folder path for Docker Hub registry tokens. Secret names must match dockerhub_registries keys."
  type        = string
  default     = "/terraform/portainer/dockerhub-registry-tokens"
}

variable "infisical_stack_env_enabled" {
  description = "Fetch Portainer stack environment variables from Infisical."
  type        = bool
  default     = false
}

variable "infisical_stack_env_path_prefix" {
  description = "Folder prefix for stack env secrets. Stack keys are appended as /<prefix>/<host>/<app>."
  type        = string
  default     = "hosts"
}

variable "infisical_stack_env_stack_keys" {
  description = "Stack keys to fetch from Infisical. Override this if only a subset has folders in Infisical."
  type        = set(string)
  default = [
    "6194cicero-gmk-g3/caddy",
    "6194cicero-gmk-g3/nebula-sync",
    "6194cicero-gmk-g3/pairdrop",
    "6194cicero-gmk-g3/pihole",
    "6194cicero-gmk-g3/speedtest",
    "6194cicero-gmk-g3/volume-backup",
    "6194cicero-raspberrypi/authelia",
    "6194cicero-raspberrypi/caddy",
    "6194cicero-raspberrypi/homer",
    "6194cicero-raspberrypi/monitoring",
    "6194cicero-raspberrypi/pihole",
    "6194cicero-raspberrypi/vaultwarden",
    "6194cicero-raspberrypi/wireguard-ls",
  ]
}

variable "infisical_stack_env_overrides" {
  description = "Per-stack Infisical read overrides. Use env_slug to test one stack against dev, or folder_path for non-standard folders."
  type = map(object({
    env_slug    = optional(string)
    folder_path = optional(string)
  }))
  default = {}
}
