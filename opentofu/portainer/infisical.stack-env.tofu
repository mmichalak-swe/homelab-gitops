locals {
  infisical_stack_env_path_prefix = trim(var.infisical_stack_env_path_prefix, "/")

  infisical_stack_env_stack_keys = setunion(
    var.infisical_stack_env_stack_keys,
    toset(keys(var.infisical_stack_env_overrides)),
  )

  infisical_stack_env_default_folder_paths = {
    for stack_key in local.infisical_stack_env_stack_keys :
    stack_key => (
      local.infisical_stack_env_path_prefix == ""
      ? "/${stack_key}"
      : "/${local.infisical_stack_env_path_prefix}/${stack_key}"
    )
    if contains(keys(local.stacks), stack_key)
  }

  infisical_stack_env_requests = {
    for stack_key, folder_path in local.infisical_stack_env_default_folder_paths :
    stack_key => {
      env_slug    = coalesce(try(var.infisical_stack_env_overrides[stack_key].env_slug, null), var.infisical_env_slug)
      folder_path = coalesce(try(var.infisical_stack_env_overrides[stack_key].folder_path, null), folder_path)
    }
  }

  infisical_stack_env = {
    for stack_key, secret_data in data.infisical_secrets.stack_env :
    stack_key => {
      for secret_name, secret in secret_data.secrets :
      secret_name => secret.value
    }
  }
}

data "infisical_secrets" "stack_env" {
  for_each = var.infisical_stack_env_enabled ? local.infisical_stack_env_requests : {}

  env_slug     = each.value.env_slug
  workspace_id = var.infisical_project_id
  folder_path  = each.value.folder_path
}
