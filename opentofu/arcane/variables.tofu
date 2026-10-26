variable "repository_url" {
  description = "Git URL for this homelab repository. Registering it does not deploy projects."
  type        = string
  nullable    = false
}

variable "repository_auth_type" {
  description = "Git authentication: none for a public repository, token or ssh for a private repository."
  type        = string
  default     = "none"

  validation {
    condition     = contains(["none", "token", "ssh"], var.repository_auth_type)
    error_message = "repository_auth_type must be none, token or ssh."
  }
}

variable "repository_username" {
  description = "Git username when using token authentication."
  type        = string
  default     = null
}

variable "repository_credential_version" {
  description = "Increment when rotating the Infisical Git credential so the provider sends the new write-only value."
  type        = number
  default     = 1

  validation {
    condition     = var.repository_credential_version >= 1 && floor(var.repository_credential_version) == var.repository_credential_version
    error_message = "repository_credential_version must be a positive integer."
  }
}
