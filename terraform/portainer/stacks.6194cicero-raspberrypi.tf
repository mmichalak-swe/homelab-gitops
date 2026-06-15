locals {
  stacks_6194cicero_raspberrypi = {
    "6194cicero-raspberrypi/authelia" = {
      name                    = "authelia"
      host                    = "6194cicero-raspberrypi"
      file_path_in_repository = "hosts/6194cicero-raspberrypi/authelia/compose.yml"
    }

    "6194cicero-raspberrypi/caddy" = {
      name                    = "caddy"
      host                    = "6194cicero-raspberrypi"
      file_path_in_repository = "hosts/6194cicero-raspberrypi/caddy/compose.yml"
    }

    "6194cicero-raspberrypi/homer" = {
      name                    = "homer"
      host                    = "6194cicero-raspberrypi"
      file_path_in_repository = "hosts/6194cicero-raspberrypi/homer/compose.yml"
    }

    "6194cicero-raspberrypi/monitoring" = {
      name                    = "monitoring"
      host                    = "6194cicero-raspberrypi"
      file_path_in_repository = "hosts/6194cicero-raspberrypi/monitoring/compose.yml"
    }

    "6194cicero-raspberrypi/pihole" = {
      name                    = "pihole"
      host                    = "6194cicero-raspberrypi"
      file_path_in_repository = "hosts/6194cicero-raspberrypi/pihole/compose.yml"
    }

    "6194cicero-raspberrypi/vaultwarden" = {
      name                    = "vaultwarden"
      host                    = "6194cicero-raspberrypi"
      file_path_in_repository = "hosts/6194cicero-raspberrypi/vaultwarden/compose.yml"
    }

    "6194cicero-raspberrypi/wireguard-ls" = {
      name                    = "wireguard-ls"
      host                    = "6194cicero-raspberrypi"
      file_path_in_repository = "hosts/6194cicero-raspberrypi/wireguard/compose.yml"
    }
  }
}
