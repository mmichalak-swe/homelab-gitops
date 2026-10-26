# Arcane creates environment 0 for the manager's local Docker connection.
# The Compose stack supplies its Docker host and projects directory.
resource "arcane_settings" "rpi4" {
  environment_id = "0"

  base_server_url            = trimsuffix(local.arcane_endpoint, "/api")
  auto_update                = "false"
  auto_heal_enabled          = "false"
  scheduled_prune_enabled    = "false"
  image_auto_patch_enabled   = "false"
  vulnerability_scan_enabled = "false"
}

# Application GitOps syncs in gitops.tofu share this repository registration.
# The manager and its socket proxy are bootstrapped manually with Compose.
resource "arcane_git_repository" "homelab" {
  name        = "homelab-gitops"
  description = "Homelab Compose sources managed with OpenTofu"
  url         = var.repository_url
  auth_type   = var.repository_auth_type
  enabled     = true
  username    = var.repository_auth_type == "token" ? var.repository_username : null

  token_wo           = var.repository_auth_type == "token" ? local.arcane_config["git_token"] : null
  token_wo_version   = var.repository_auth_type == "token" ? var.repository_credential_version : null
  ssh_key_wo         = var.repository_auth_type == "ssh" ? local.arcane_config["git_ssh_key"] : null
  ssh_key_wo_version = var.repository_auth_type == "ssh" ? var.repository_credential_version : null
}
