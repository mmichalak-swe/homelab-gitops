terraform {
  required_version = ">= 1.15.0"

  required_providers {
    portainer = {
      source  = "registry.opentofu.org/portainer/portainer"
      version = "1.31.1"
    }
  }
}
