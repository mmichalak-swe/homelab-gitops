provider "infisical" {
  host = var.infisical_host
  auth = var.infisical_auth
}

provider "arcane" {
  endpoint = local.arcane_endpoint
  api_key  = local.arcane_config["arcane_api_key"]
}
