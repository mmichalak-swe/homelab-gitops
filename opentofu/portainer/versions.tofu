language {
  compatible_with {
    opentofu = ">= 1.12"
  }
}

terraform {
  required_providers {
    infisical = {
      source  = "registry.opentofu.org/infisical/infisical"
      version = "0.19.6"
    }

    portainer = {
      source  = "registry.opentofu.org/portainer/portainer"
      version = "1.34.0"
    }
  }
}
