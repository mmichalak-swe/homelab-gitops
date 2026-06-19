variable "name" {
  description = "Portainer stack name."
  type        = string
}

variable "deployment_type" {
  description = "Portainer stack deployment type."
  type        = string
  default     = "standalone"

  validation {
    condition     = contains(["standalone", "swarm", "kubernetes"], var.deployment_type)
    error_message = "deployment_type must be one of: standalone, swarm, kubernetes."
  }
}

variable "endpoint_id" {
  description = "Portainer environment/endpoint ID."
  type        = number
}

variable "repository_url" {
  description = "Git repository URL Portainer should use for the stack."
  type        = string
}

variable "repository_reference_name" {
  description = "Git reference Portainer should track, for example refs/heads/main."
  type        = string
}

variable "file_path_in_repository" {
  description = "Path to the compose file in the Git repository."
  type        = string
}

variable "additional_files" {
  description = "Additional compose or manifest files in the Git repository."
  type        = list(string)
  default     = []
}

variable "active" {
  description = "Whether the stack should be running."
  type        = bool
  default     = true
}

variable "authorized_teams" {
  description = "Portainer team IDs allowed when ownership is restricted."
  type        = set(number)
  default     = []
}

variable "authorized_users" {
  description = "Portainer user IDs allowed when ownership is restricted."
  type        = set(number)
  default     = []
}

variable "env" {
  description = "Stack environment variables configured in Portainer."
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "force_update" {
  description = "Force Portainer to redeploy the stack on update."
  type        = bool
  default     = false
}

variable "git_repository_authentication" {
  description = "Whether Portainer should authenticate to the Git repository."
  type        = bool
  default     = false
}

variable "ownership" {
  description = "Portainer stack ownership mode."
  type        = string
  default     = "administrators"

  validation {
    condition     = contains(["public", "administrators", "restricted", "private"], var.ownership)
    error_message = "ownership must be one of: public, administrators, restricted, private."
  }
}

variable "prune" {
  description = "Remove services no longer present in the compose file."
  type        = bool
  default     = true
}

variable "pull_image" {
  description = "Pull images when Portainer updates the stack."
  type        = bool
  default     = false
}

variable "repository_git_credential_id" {
  description = "Existing Portainer Git credential ID to use for repository authentication."
  type        = number
  default     = null
}

variable "stack_webhook" {
  description = "Enable the Portainer stack webhook."
  type        = bool
  default     = false
}

variable "support_relative_path" {
  description = "Enable Portainer support for resolving relative paths."
  type        = bool
  default     = false
}

variable "tlsskip_verify" {
  description = "Skip TLS verification when Portainer fetches the Git repository."
  type        = bool
  default     = false
}

variable "update_interval" {
  description = "Portainer GitOps polling interval, for example 5m. Use null to leave unset."
  type        = string
  default     = "1h"
}
