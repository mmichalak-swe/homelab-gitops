language {
  compatible_with {
    opentofu = ">= 1.12"
  }
}

terraform {
  backend "s3" {
    key          = "aws/iam-roles-anywhere/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "registry.opentofu.org/hashicorp/aws"
      version = "6.63.0"
    }

    tls = {
      source  = "registry.opentofu.org/hashicorp/tls"
      version = "4.3.0"
    }
  }
}
