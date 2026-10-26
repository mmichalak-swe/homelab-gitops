language {
  compatible_with {
    opentofu = ">= 1.13"
  }
}

terraform {
  backend "s3" {
    key          = "arcane/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    arcane = {
      source  = "registry.terraform.io/hellscrimson/arcane"
      version = "1.5.0"
    }

    infisical = {
      source  = "registry.opentofu.org/infisical/infisical"
      version = "0.20.5"
    }
  }
}
