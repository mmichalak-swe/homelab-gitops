locals {
  # Defaults for entries in the committed per-host inventories.
  gitops_stack_defaults = {
    compose_path          = null
    branch                = null
    auto_sync             = true
    sync_interval_minutes = 60
    sync_directory        = true
    start_project         = false
    redeploy_after_sync   = false
    pull_image_after_sync = false
    infisical_enabled     = true
    infisical_env_slug    = null
    infisical_folder_path = null
  }

  # Keep existing tfvars entries supported. A matching key replaces the full
  # host-file entry; keep application definitions in the host files normally.
  gitops_stacks = {
    for key, stack in merge(
      local.stacks_6194cicero_raspberrypi,
      local.stacks_6194cicero_gmk_g3,
      var.gitops_stacks,
    ) : key => merge(local.gitops_stack_defaults, stack)
  }
}
