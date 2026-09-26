language {
  compatible_with {
    opentofu = ">= 1.12"
  }
}

terraform {
  backend "s3" {
    key          = "portainer/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    infisical = {
      source  = "registry.opentofu.org/infisical/infisical"
      version = "0.19.36"
    }

    portainer = {
      source  = "registry.opentofu.org/portainer/portainer"
      version = "2.0.0"
    }
  }
}
