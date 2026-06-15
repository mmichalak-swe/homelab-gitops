variable "portainer_endpoint" {
  description = "Portainer API endpoint. Prefer the Infisical portainer_endpoint secret or a local, ignored tfvars value."
  type        = string
  default     = null
}

variable "portainer_api_key" {
  description = "Portainer API key. Prefer the Infisical portainer_api_key secret or a local, ignored tfvars value."
  type        = string
  default     = null
  sensitive   = true
}

variable "portainer_api_user" {
  description = "Optional Portainer username for password authentication. Prefer portainer_api_key."
  type        = string
  default     = null
}

variable "portainer_api_password" {
  description = "Optional Portainer password for password authentication. Prefer portainer_api_key."
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
