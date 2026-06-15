locals {
  infisical_dockerhub_registry_tokens_env_slug = coalesce(var.infisical_dockerhub_registry_tokens_env_slug, var.infisical_env_slug)

  infisical_dockerhub_registry_tokens = try({
    for secret_name, secret in data.infisical_secrets.dockerhub_registry_tokens[0].secrets :
    secret_name => secret.value
  }, {})

  dockerhub_registry_tokens = merge(
    var.dockerhub_registry_tokens,
    local.infisical_dockerhub_registry_tokens,
  )
}

data "infisical_secrets" "dockerhub_registry_tokens" {
  count = var.infisical_dockerhub_registry_tokens_enabled ? 1 : 0

  env_slug     = local.infisical_dockerhub_registry_tokens_env_slug
  workspace_id = var.infisical_project_id
  folder_path  = var.infisical_dockerhub_registry_tokens_path
}
