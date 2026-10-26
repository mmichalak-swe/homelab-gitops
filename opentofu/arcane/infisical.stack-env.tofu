data "infisical_secrets" "stack_env" {
  for_each = { for key, stack in local.gitops_stacks : key => stack if stack.infisical_enabled }

  env_slug     = coalesce(each.value.infisical_env_slug, var.infisical_env_slug)
  workspace_id = var.infisical_project_id
  folder_path  = coalesce(each.value.infisical_folder_path, "/hosts/${each.key}")
}

locals {
  infisical_stack_env = {
    for key, secret_data in data.infisical_secrets.stack_env : key => {
      for name, secret in secret_data.secrets : name => secret.value
    }
  }
}
