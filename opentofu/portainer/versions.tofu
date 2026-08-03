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
    aws = {
      source  = "registry.opentofu.org/hashicorp/aws"
      version = "6.57.1"
    }

    infisical = {
      source  = "registry.opentofu.org/infisical/infisical"
      version = "0.19.6"
    }

    portainer = {
      source  = "registry.opentofu.org/portainer/portainer"
      version = "1.34.3"
    }
  }
}
