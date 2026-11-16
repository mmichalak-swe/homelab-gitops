data "infisical_secrets" "dockerhub_registry_tokens" {
  count = length(var.dockerhub_registries) > 0 ? 1 : 0

  env_slug     = var.infisical_env_slug
  workspace_id = var.infisical_project_id
  folder_path  = var.infisical_dockerhub_registry_tokens_path

  lifecycle {
    postcondition {
      condition = alltrue([
        for key in keys(var.dockerhub_registries) :
        try(trimspace(self.secrets[key].value) != "", false)
      ])
      error_message = "The registry token folder must contain a non-empty secret for every dockerhub_registries key."
    }
  }
}

resource "arcane_container_registry" "dockerhub" {
  for_each = var.dockerhub_registries

  url              = each.value.url
  username         = each.value.username
  description      = each.value.name
  enabled          = true
  insecure         = false
  repository_names = each.value.repository_names

  token_wo         = data.infisical_secrets.dockerhub_registry_tokens[0].secrets[each.key].value
  token_wo_version = each.value.credential_version
}
