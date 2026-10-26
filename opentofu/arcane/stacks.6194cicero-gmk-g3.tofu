locals {
  stacks_6194cicero_gmk_g3 = {
    # Example: enable only after handing PairDrop over from Portainer.
    # Bootstrap the GMK Arcane agent first, then replace the environment ID.
    # Creation performs an initial Git sync even with auto_sync = false.
    # "6194cicero-gmk-g3/pairdrop" = {
    #   name                  = "pairdrop"
    #   environment_id        = "REPLACE_WITH_GMK_ENVIRONMENT_ID"
    #   compose_path          = "hosts/6194cicero-gmk-g3/pairdrop/compose.yml"
    #   auto_sync             = false
    #   sync_interval_minutes = 60
    #   start_project         = false
    #   infisical_enabled     = true # Reads /hosts/6194cicero-gmk-g3/pairdrop.
    # }
  }
}
