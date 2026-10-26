output "rpi4_environment_id" {
  description = "Arcane's built-in environment for the manager on the Pi."
  value       = arcane_settings.rpi4.id
}

output "repository_id" {
  description = "Registered homelab repository ID used by application GitOps syncs."
  value       = arcane_git_repository.homelab.id
}

output "gitops_sync_ids" {
  description = "Application GitOps sync IDs keyed by host/app."
  value       = { for key, sync in arcane_gitops_sync.stacks : key => sync.id }
}

output "project_ids" {
  description = "Arcane project IDs associated with application GitOps syncs."
  value       = { for key, sync in arcane_gitops_sync.stacks : key => sync.project_id }
}
