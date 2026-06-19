locals {
  infisical_portainer_config_env_slug = coalesce(var.infisical_portainer_config_env_slug, var.infisical_env_slug)

  infisical_portainer_config = try({
    for secret_name, secret in data.infisical_secrets.portainer_config[0].secrets :
    secret_name => secret.value
  }, {})

  portainer_endpoint = try(nonsensitive(local.infisical_portainer_config["portainer_endpoint"]), var.portainer_endpoint)
  portainer_api_key  = try(local.infisical_portainer_config["portainer_api_key"], var.portainer_api_key)
}

data "infisical_secrets" "portainer_config" {
  count = var.infisical_portainer_config_enabled ? 1 : 0

  env_slug     = local.infisical_portainer_config_env_slug
  workspace_id = var.infisical_project_id
  folder_path  = var.infisical_portainer_config_path
}
