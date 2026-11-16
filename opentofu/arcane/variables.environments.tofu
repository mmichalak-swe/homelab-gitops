variable "gmk_environment_enabled" {
  description = "Register GMK in Arcane and generate its pairing token. Bootstrap the agent manually after applying."
  type        = bool
  default     = false
  nullable    = false
}

variable "gmk_settings_enabled" {
  description = "Manage GMK automation settings after the manually bootstrapped agent is online. Keep enabled after setup."
  type        = bool
  default     = false
  nullable    = false

  validation {
    condition     = !var.gmk_settings_enabled || var.gmk_environment_enabled
    error_message = "gmk_settings_enabled requires gmk_environment_enabled."
  }
}

