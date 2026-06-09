provider "portainer" {
  endpoint        = var.portainer_endpoint
  api_key         = var.portainer_api_key
  api_user        = var.portainer_api_user
  api_password    = var.portainer_api_password
  skip_ssl_verify = var.portainer_skip_ssl_verify
}

