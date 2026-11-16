output "rpi4_environment_id" {
  description = "Arcane's built-in environment for the manager on the Pi."
  value       = arcane_settings.rpi4.id
}

output "gmk_environment_id" {
  description = "GMK environment ID for application GitOps syncs; null until registration is enabled."
  value       = try(arcane_environment.gmk[0].id, null)
}

output "gmk_agent_pairing_token" {
  description = "Initial generated pairing token. Store it as AGENT_TOKEN in GMK's Infisical bootstrap folder; this output is not a token-rotation mechanism."
  value       = try(arcane_environment.gmk[0].api_key, null)
  sensitive   = true
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

output "dockerhub_registry_ids" {
  description = "Arcane registry IDs, keyed by the registry configuration key."
  value       = { for key, registry in arcane_container_registry.dockerhub : key => registry.id }
}

output "standard_compose_template_id" {
  description = "Arcane's reusable Compose template ID; this does not deploy a project."
  value       = arcane_template.standard_compose.id
}
