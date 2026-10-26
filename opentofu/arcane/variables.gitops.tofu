variable "repository_branch" {
  description = "Default Git branch for application syncs, without the refs/heads/ prefix."
  type        = string
  default     = "main"
}

variable "gitops_stacks" {
  description = "Optional additional application definitions or full-entry overrides for stacks.<host>.tofu, keyed by host/app. Normally maintain applications in the host files; never include the manually bootstrapped managers."
  type = map(object({
    name                  = string
    environment_id        = string
    compose_path          = optional(string)
    branch                = optional(string)
    auto_sync             = optional(bool, true)
    sync_interval_minutes = optional(number, 60)
    sync_directory        = optional(bool, true)
    start_project         = optional(bool, false)
    redeploy_after_sync   = optional(bool, false)
    pull_image_after_sync = optional(bool, false)
    infisical_enabled     = optional(bool, true)
    infisical_env_slug    = optional(string)
    infisical_folder_path = optional(string)
  }))
  default  = {}
  nullable = false

}

variable "stack_env" {
  description = "Optional per-stack environment values. Infisical values override these; keep secrets in Infisical."
  type        = map(map(string))
  default     = {}
  sensitive   = true
}
