locals {
  stacks_6194cicero_raspberrypi = {
    # Example: enable only after handing Homer over from Portainer.
    # Creation performs an initial Git sync even with auto_sync = false.
    # "6194cicero-raspberrypi/homer" = {
    #   name                  = "homer" # Preserve the existing Compose project name.
    #   environment_id        = "0"     # The manager's local Docker environment.
    #   compose_path          = "hosts/6194cicero-raspberrypi/homer/compose.yml"
    #   auto_sync             = false   # Enable after verifying the first deployment.
    #   sync_interval_minutes = 60
    #   start_project         = false
    #   infisical_enabled     = false   # Homer needs no injected environment values.
    # }
  }
}
