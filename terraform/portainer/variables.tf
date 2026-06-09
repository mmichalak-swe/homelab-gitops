variable "portainer_endpoint" {
  description = "Portainer API endpoint. Can also be set with PORTAINER_ENDPOINT."
  type        = string
  default     = null
}

variable "portainer_api_key" {
  description = "Portainer API key. Prefer PORTAINER_API_KEY instead of committing this value."
  type        = string
  default     = null
  sensitive   = true
}

variable "portainer_api_user" {
  description = "Portainer username. Can also be set with PORTAINER_USER."
  type        = string
  default     = null
}

variable "portainer_api_password" {
  description = "Portainer password. Prefer PORTAINER_PASSWORD instead of committing this value."
  type        = string
  default     = null
  sensitive   = true
}

variable "portainer_skip_ssl_verify" {
  description = "Skip TLS certificate verification for the Portainer API client."
  type        = bool
  default     = false
}

variable "repository_url" {
  description = "Git repository URL that Portainer uses for stack deployments."
  type        = string
}

variable "repository_reference_name" {
  description = "Git reference that Portainer tracks for stack deployments."
  type        = string
  default     = "refs/heads/main"
}

variable "stack_repository_reference_names" {
  description = "Per-stack Git references for stacks that do not track the global repository_reference_name."
  type        = map(string)
  default     = {}
}

variable "portainer_environment_names" {
  description = "Map from repo host key to the matching Portainer environment name."
  type        = map(string)

  default = {
    "6194cicero-gmk-g3"      = "6194cicero-gmk-g3"
    "6194cicero-raspberrypi" = "6194cicero-raspberrypi"
  }
}

variable "git_repository_authentication" {
  description = "Whether Portainer should authenticate to the Git repository."
  type        = bool
  default     = false
}

variable "repository_git_credential_id" {
  description = "Existing Portainer Git credential ID to use for repository authentication."
  type        = number
  default     = null
}

variable "dockerhub_registries" {
  description = "Docker Hub registries to register in Portainer. The map key must also exist in dockerhub_registry_tokens. Use type 6 for Docker Hub."
  type = map(object({
    authentication = bool
    name           = string
    type           = number
    username       = string
    url            = optional(string, "docker.io")
  }))
  default = {}
}

variable "dockerhub_registry_tokens" {
  description = "Docker Hub personal access tokens, keyed by dockerhub_registries key."
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "stack_defaults" {
  description = "Default behavior for Portainer Git-backed stacks."
  type = object({
    force_update          = bool
    ownership             = string
    prune                 = bool
    pull_image            = bool
    stack_webhook         = bool
    support_relative_path = bool
    tlsskip_verify        = bool
    update_interval       = string
  })

  default = {
    force_update          = false
    ownership             = "administrators"
    prune                 = true
    pull_image            = false
    stack_webhook         = false
    support_relative_path = false
    tlsskip_verify        = false
    update_interval       = "1h"
  }
}

variable "stack_env" {
  description = "Per-stack environment variables configured in Portainer. Keep sensitive values in a local, ignored tfvars file or another secure variable source."
  type        = map(map(string))

  default = {
    "6194cicero-gmk-g3/caddy"             = {}
    "6194cicero-gmk-g3/nebula-sync"       = {}
    "6194cicero-gmk-g3/pairdrop"          = {}
    "6194cicero-gmk-g3/pihole"            = {}
    "6194cicero-gmk-g3/speedtest"         = {}
    "6194cicero-gmk-g3/volume-backup"     = {}
    "6194cicero-raspberrypi/authelia"     = {}
    "6194cicero-raspberrypi/caddy"        = {}
    "6194cicero-raspberrypi/homer"        = {}
    "6194cicero-raspberrypi/monitoring"   = {}
    "6194cicero-raspberrypi/pihole"       = {}
    "6194cicero-raspberrypi/vaultwarden"  = {}
    "6194cicero-raspberrypi/wireguard-ls" = {}
  }
}
