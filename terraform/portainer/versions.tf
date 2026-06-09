terraform {
  required_version = ">= 1.15.0"

  required_providers {
    portainer = {
      source  = "portainer/portainer"
      version = "1.31.1"
    }
  }
}
