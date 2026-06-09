locals {
  stacks = merge(
    local.stacks_6194cicero_gmk_g3,
    local.stacks_6194cicero_raspberrypi,
  )
}

module "stack" {
  source = "../modules/portainer-stack"

  for_each = local.stacks

  name        = each.value.name
  endpoint_id = tonumber(data.portainer_environment.host[each.value.host].id)

  repository_url            = var.repository_url
  repository_reference_name = try(each.value.repository_reference_name, var.repository_reference_name)
  file_path_in_repository   = each.value.file_path_in_repository

  env = each.value.env

  force_update                  = try(each.value.force_update, var.stack_defaults.force_update)
  git_repository_authentication = var.git_repository_authentication
  ownership                     = try(each.value.ownership, var.stack_defaults.ownership)
  prune                         = try(each.value.prune, var.stack_defaults.prune)
  pull_image                    = try(each.value.pull_image, var.stack_defaults.pull_image)
  repository_git_credential_id  = var.repository_git_credential_id
  stack_webhook                 = try(each.value.stack_webhook, var.stack_defaults.stack_webhook)
  support_relative_path         = try(each.value.support_relative_path, var.stack_defaults.support_relative_path)
  tlsskip_verify                = try(each.value.tlsskip_verify, var.stack_defaults.tlsskip_verify)
  update_interval               = try(each.value.update_interval, var.stack_defaults.update_interval)
}
