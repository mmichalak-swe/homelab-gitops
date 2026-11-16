# Register the remote Docker host before manually bootstrapping its agent.
resource "arcane_environment" "gmk" {
  count = var.gmk_environment_enabled ? 1 : 0

  name               = "6194cicero-gmk-g3"
  api_url            = trimsuffix(try(local.arcane_config["gmk_agent_api_url"], ""), "/")
  enabled            = true
  is_edge            = false
  use_api_key        = true
  regenerate_api_key = false

  lifecycle {
    prevent_destroy = true

    precondition {
      condition     = can(regex("^https?://[^/?#@]+/?$", try(local.arcane_config["gmk_agent_api_url"], "")))
      error_message = "Set gmk_agent_api_url in the Arcane Infisical config folder to the manager-reachable agent origin, for example http://<gmk-lan-ip>:3553 (without /api)."
    }
  }
}

# Settings requests are proxied to the agent. Enable this only once it is online
# so the first environment-registration apply does not require a running agent.
resource "arcane_settings" "gmk" {
  count = var.gmk_environment_enabled && var.gmk_settings_enabled ? 1 : 0

  environment_id = arcane_environment.gmk[0].id

  auto_update                 = "false"
  polling_enabled             = "false"
  image_event_watcher_enabled = "false"
  auto_heal_enabled           = "false"
  scheduled_prune_enabled     = "false"
  image_auto_patch_enabled    = "false"
  vulnerability_scan_enabled  = "false"
}
