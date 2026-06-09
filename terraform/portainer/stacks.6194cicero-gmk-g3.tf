locals {
  stacks_6194cicero_gmk_g3 = {
    "6194cicero-gmk-g3/actual-budget" = {
      name                    = "actual-budget"
      host                    = "6194cicero-gmk-g3"
      file_path_in_repository = "hosts/6194cicero-gmk-g3/actual-budget/compose.yml"
      env                     = {}
    }

    "6194cicero-gmk-g3/caddy" = {
      name                    = "caddy"
      host                    = "6194cicero-gmk-g3"
      file_path_in_repository = "hosts/6194cicero-gmk-g3/caddy/compose.yml"
      env                     = try(var.stack_env["6194cicero-gmk-g3/caddy"], {})
      repository_reference_name = lookup(var.stack_repository_reference_names, "6194cicero-gmk-g3/caddy", var.repository_reference_name)
    }

    "6194cicero-gmk-g3/drawio" = {
      name                    = "drawio"
      host                    = "6194cicero-gmk-g3"
      file_path_in_repository = "hosts/6194cicero-gmk-g3/drawio/compose.yml"
      env                     = {}
    }

    "6194cicero-gmk-g3/nebula-sync" = {
      name                    = "nebula-sync"
      host                    = "6194cicero-gmk-g3"
      file_path_in_repository = "hosts/6194cicero-gmk-g3/nebula-sync/compose.yml"
      env                     = try(var.stack_env["6194cicero-gmk-g3/nebula-sync"], {})
    }

    "6194cicero-gmk-g3/pairdrop" = {
      name                    = "pairdrop"
      host                    = "6194cicero-gmk-g3"
      file_path_in_repository = "hosts/6194cicero-gmk-g3/pairdrop/compose.yml"
      env                     = try(var.stack_env["6194cicero-gmk-g3/pairdrop"], {})
    }

    "6194cicero-gmk-g3/pihole" = {
      name                    = "pihole"
      host                    = "6194cicero-gmk-g3"
      file_path_in_repository = "hosts/6194cicero-gmk-g3/pihole/compose.yml"
      env                     = try(var.stack_env["6194cicero-gmk-g3/pihole"], {})
    }

    "6194cicero-gmk-g3/speedtest" = {
      name                    = "speedtest"
      host                    = "6194cicero-gmk-g3"
      file_path_in_repository = "hosts/6194cicero-gmk-g3/speedtest/compose.yml"
      env                     = try(var.stack_env["6194cicero-gmk-g3/speedtest"], {})
    }

    "6194cicero-gmk-g3/volume-backup" = {
      name                      = "volume-backup"
      host                      = "6194cicero-gmk-g3"
      repository_reference_name = lookup(var.stack_repository_reference_names, "6194cicero-gmk-g3/volume-backup", var.repository_reference_name)
      file_path_in_repository   = "hosts/6194cicero-gmk-g3/volume-backup/compose.yml"
      env                       = try(var.stack_env["6194cicero-gmk-g3/volume-backup"], {})
      update_interval           = "24h"
    }
  }
}
