resource "arcane_settings" "rpi4" {
  environment_id = "0"

  base_server_url             = trimsuffix(local.arcane_endpoint, "/api")
  auto_update                 = "false"
  polling_enabled             = "false"
  image_event_watcher_enabled = "false"
  auto_heal_enabled           = "false"
  scheduled_prune_enabled     = "false"
  image_auto_patch_enabled    = "false"
  vulnerability_scan_enabled  = "true"
}

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
