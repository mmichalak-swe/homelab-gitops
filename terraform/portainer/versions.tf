terraform {
  required_version = ">= 1.15.0"

  required_providers {
    infisical = {
      source  = "registry.opentofu.org/infisical/infisical"
      version = "0.16.28"
    }

    portainer = {
      source  = "registry.opentofu.org/portainer/portainer"
      version = "1.31.1"
    }
  }
}
