locals {
  stacks_6194cicero_gmk_g3 = {
    "6194cicero-gmk-g3/actual-budget" = {
      name              = "actual-budget"
      environment_id    = arcane_environment.gmk[0].id
      compose_path      = "hosts/6194cicero-gmk-g3/actual-budget/compose.yml"
      auto_sync         = true
      start_project     = true
      infisical_enabled = true
    }

    "6194cicero-gmk-g3/beszel" = {
      name              = "beszel"
      environment_id    = arcane_environment.gmk[0].id
      compose_path      = "hosts/6194cicero-gmk-g3/beszel/compose.yml"
      auto_sync         = true
      start_project     = true
      infisical_enabled = true
    }

    "6194cicero-gmk-g3/caddy" = {
      name              = "caddy"
      environment_id    = arcane_environment.gmk[0].id
      compose_path      = "hosts/6194cicero-gmk-g3/caddy/compose.yml"
      auto_sync         = true
      start_project     = true
      infisical_enabled = true
    }

    "6194cicero-gmk-g3/drawio" = {
      name              = "drawio"
      environment_id    = arcane_environment.gmk[0].id
      compose_path      = "hosts/6194cicero-gmk-g3/drawio/compose.yml"
      auto_sync         = true
      start_project     = true
      infisical_enabled = false
    }

    "6194cicero-gmk-g3/home-assistant" = {
      name              = "home-assistant"
      environment_id    = arcane_environment.gmk[0].id
      compose_path      = "hosts/6194cicero-gmk-g3/home-assistant/compose.yml"
      auto_sync         = true
      start_project     = true
      infisical_enabled = true
    }

    "6194cicero-gmk-g3/nebula-sync" = {
      name              = "nebula-sync"
      environment_id    = arcane_environment.gmk[0].id
      compose_path      = "hosts/6194cicero-gmk-g3/nebula-sync/compose.yml"
      auto_sync         = true
      start_project     = true
      infisical_enabled = true
    }

    "6194cicero-gmk-g3/pairdrop" = {
      name              = "pairdrop"
      environment_id    = arcane_environment.gmk[0].id
      compose_path      = "hosts/6194cicero-gmk-g3/pairdrop/compose.yml"
      auto_sync         = true
      start_project     = true
      infisical_enabled = true
    }

    "6194cicero-gmk-g3/pihole" = {
      name              = "pihole"
      environment_id    = arcane_environment.gmk[0].id
      compose_path      = "hosts/6194cicero-gmk-g3/pihole/compose.yml"
      auto_sync         = true
      start_project     = true
      infisical_enabled = true
    }

    "6194cicero-gmk-g3/speedtest" = {
      name              = "speedtest"
      environment_id    = arcane_environment.gmk[0].id
      compose_path      = "hosts/6194cicero-gmk-g3/speedtest/compose.yml"
      auto_sync         = true
      start_project     = true
      infisical_enabled = true
    }

    # Preserve the inactive experiment and its existing non-default Git branch.
    # Its Compose file is absent from main. Keep it stopped; see README.md.
    "6194cicero-gmk-g3/volume-backup" = {
      name                  = "volume-backup"
      environment_id        = arcane_environment.gmk[0].id
      compose_path          = "hosts/6194cicero-gmk-g3/volume-backup/compose.yml"
      branch                = "add-docker-volume-backup-test-tzdata"
      auto_sync             = false
      start_project         = false
      redeploy_after_sync   = false
      pull_image_after_sync = false
      infisical_enabled     = true
    }
  }
}
