variable "stack_defaults" {
  description = "Default behavior for Portainer Git-backed stacks."
  type = object({
    force_update          = bool
    ownership             = string
    prune                 = bool
    pull_image            = bool
    stack_webhook         = bool
    support_relative_path = bool
    tlsskip_verify        = bool
    update_interval       = string
  })

  default = {
    force_update          = false
    ownership             = "administrators"
    prune                 = true
    pull_image            = false
    stack_webhook         = false
    support_relative_path = false
    tlsskip_verify        = false
    update_interval       = "1h"
  }
}

variable "stack_env" {
  description = "Per-stack environment variables configured in Portainer. Infisical values override this map when infisical_stack_env_enabled is true."
  type        = map(map(string))
  sensitive   = true

  default = {
    "6194cicero-gmk-g3/caddy"             = {}
    "6194cicero-gmk-g3/nebula-sync"       = {}
    "6194cicero-gmk-g3/pairdrop"          = {}
    "6194cicero-gmk-g3/pihole"            = {}
    "6194cicero-gmk-g3/speedtest"         = {}
    "6194cicero-gmk-g3/volume-backup"     = {}
    "6194cicero-raspberrypi/authelia"     = {}
    "6194cicero-raspberrypi/caddy"        = {}
    "6194cicero-raspberrypi/homer"        = {}
    "6194cicero-raspberrypi/monitoring"   = {}
    "6194cicero-raspberrypi/pihole"       = {}
    "6194cicero-raspberrypi/vaultwarden"  = {}
    "6194cicero-raspberrypi/wireguard-ls" = {}
  }
}
