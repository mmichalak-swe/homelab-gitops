resource "portainer_stack" "this" {
  name            = var.name
  deployment_type = var.deployment_type
  method          = "repository"
  endpoint_id     = var.endpoint_id

  repository_url            = var.repository_url
  repository_reference_name = var.repository_reference_name
  file_path_in_repository   = var.file_path_in_repository

  additional_files              = var.additional_files
  active                        = var.active
  authorized_teams              = var.authorized_teams
  authorized_users              = var.authorized_users
  force_update                  = var.force_update
  git_repository_authentication = var.git_repository_authentication
  ownership                     = var.ownership
  prune                         = var.prune
  pull_image                    = var.pull_image
  repository_git_credential_id  = var.repository_git_credential_id
  stack_webhook                 = var.stack_webhook
  support_relative_path         = var.support_relative_path
  tlsskip_verify                = var.tlsskip_verify
  update_interval               = var.update_interval

  dynamic "env" {
    for_each = var.env

    content {
      name  = env.key
      value = env.value
    }
  }
}

