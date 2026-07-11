locals {
  stacks_6194cicero_gmk_g3 = {
    "6194cicero-gmk-g3/actual-budget" = {
      name                    = "actual-budget"
      host                    = "6194cicero-gmk-g3"
      file_path_in_repository = "hosts/6194cicero-gmk-g3/actual-budget/compose.yml"
    }

    "6194cicero-gmk-g3/caddy" = {
      name                    = "caddy"
      host                    = "6194cicero-gmk-g3"
      file_path_in_repository = "hosts/6194cicero-gmk-g3/caddy/compose.yml"
    }

    "6194cicero-gmk-g3/drawio" = {
      name                    = "drawio"
      host                    = "6194cicero-gmk-g3"
      file_path_in_repository = "hosts/6194cicero-gmk-g3/drawio/compose.yml"
    }

    "6194cicero-gmk-g3/nebula-sync" = {
      name                    = "nebula-sync"
      host                    = "6194cicero-gmk-g3"
      file_path_in_repository = "hosts/6194cicero-gmk-g3/nebula-sync/compose.yml"
    }

    "6194cicero-gmk-g3/pairdrop" = {
      name                    = "pairdrop"
      host                    = "6194cicero-gmk-g3"
      file_path_in_repository = "hosts/6194cicero-gmk-g3/pairdrop/compose.yml"
    }

    "6194cicero-gmk-g3/pihole" = {
      name                    = "pihole"
      host                    = "6194cicero-gmk-g3"
      file_path_in_repository = "hosts/6194cicero-gmk-g3/pihole/compose.yml"
    }

    "6194cicero-gmk-g3/speedtest" = {
      name                    = "speedtest"
      host                    = "6194cicero-gmk-g3"
      file_path_in_repository = "hosts/6194cicero-gmk-g3/speedtest/compose.yml"
    }

    "6194cicero-gmk-g3/volume-backup" = {
      name                      = "volume-backup"
      host                      = "6194cicero-gmk-g3"
      repository_reference_name = lookup(var.stack_repository_reference_names, "6194cicero-gmk-g3/volume-backup", var.repository_reference_name)
      file_path_in_repository   = "hosts/6194cicero-gmk-g3/volume-backup/compose.yml"
      update_interval           = "24h"
    }
  }
}
