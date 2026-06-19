language {
  compatible_with {
    opentofu = ">= 1.12"
  }
}

terraform {
  required_providers {
    portainer = {
      source = "registry.opentofu.org/portainer/portainer"
    }
  }
}
