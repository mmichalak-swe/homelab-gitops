locals {
  stacks_6194cicero_raspberrypi = {
    "6194cicero-raspberrypi/authelia" = {
      name              = "authelia"
      environment_id    = "0"
      compose_path      = "hosts/6194cicero-raspberrypi/authelia/compose.yml"
      auto_sync         = true
      start_project     = true
      infisical_enabled = true
    }

    "6194cicero-raspberrypi/beszel" = {
      name              = "beszel"
      environment_id    = "0"
      compose_path      = "hosts/6194cicero-raspberrypi/beszel/compose.yml"
      auto_sync         = true
      start_project     = true
      infisical_enabled = true
    }

    "6194cicero-raspberrypi/caddy" = {
      name              = "caddy"
      environment_id    = "0"
      compose_path      = "hosts/6194cicero-raspberrypi/caddy/compose.yml"
      auto_sync         = true
      start_project     = true
      infisical_enabled = true
    }

    "6194cicero-raspberrypi/homer" = {
      name              = "homer"
      environment_id    = "0"
      compose_path      = "hosts/6194cicero-raspberrypi/homer/compose.yml"
      auto_sync         = true
      start_project     = true
      infisical_enabled = true
    }

    "6194cicero-raspberrypi/pihole" = {
      name              = "pihole"
      environment_id    = "0"
      compose_path      = "hosts/6194cicero-raspberrypi/pihole/compose.yml"
      auto_sync         = true
      start_project     = true
      infisical_enabled = true
    }

    "6194cicero-raspberrypi/vaultwarden" = {
      name              = "vaultwarden"
      environment_id    = "0"
      compose_path      = "hosts/6194cicero-raspberrypi/vaultwarden/compose.yml"
      auto_sync         = true
      start_project     = true
      infisical_enabled = true
    }

    "6194cicero-raspberrypi/wireguard-ls" = {
      name              = "wireguard-ls"
      environment_id    = "0"
      compose_path      = "hosts/6194cicero-raspberrypi/wireguard/compose.yml"
      auto_sync         = true
      start_project     = true
      infisical_enabled = true
    }
  }
}
