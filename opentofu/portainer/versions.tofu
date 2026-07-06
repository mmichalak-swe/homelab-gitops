language {
  compatible_with {
    opentofu = ">= 1.12"
  }
}

terraform {
  required_providers {
    infisical = {
      source  = "registry.opentofu.org/infisical/infisical"
      version = "0.16.32"
    }

    portainer = {
      source  = "registry.opentofu.org/portainer/portainer"
      version = "1.33.0"
    }
  }
}
