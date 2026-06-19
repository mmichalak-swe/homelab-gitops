provider "portainer" {
  endpoint        = local.portainer_endpoint
  api_key         = local.portainer_api_key
  api_user        = var.portainer_api_user
  api_password    = var.portainer_api_password
  skip_ssl_verify = var.portainer_skip_ssl_verify
}

provider "infisical" {
  host = var.infisical_host
  auth = var.infisical_auth
}
