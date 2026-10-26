# Each sync follows one application's Compose file in the shared repository.
# Arcane itself stays outside this inventory and is started manually on the Pi.
resource "arcane_gitops_sync" "stacks" {
  for_each = local.gitops_stacks

  environment_id = each.value.environment_id
  name           = each.value.name
  project_name   = each.value.name
  repository_id  = arcane_git_repository.homelab.id
  branch         = coalesce(each.value.branch, var.repository_branch)
  compose_path   = coalesce(each.value.compose_path, "hosts/${each.key}/compose.yml")

  auto_sync = each.value.auto_sync
  # Arcane's scheduler uses minutes; the v1.5.0 provider passes this unchanged
  # despite describing it as seconds in its generated documentation.
  sync_interval         = each.value.sync_interval_minutes
  sync_directory        = each.value.sync_directory
  start_project         = each.value.start_project
  redeploy_after_sync   = each.value.redeploy_after_sync
  pull_image_after_sync = each.value.pull_image_after_sync
  fail_if_name_exists   = true
  stop_before_rename    = false

  environment_variables = merge(
    lookup(var.stack_env, each.key, {}),
    lookup(local.infisical_stack_env, each.key, {}),
  )

  # Disabling manager-wide updates/pruning must precede application syncs.
  depends_on = [arcane_settings.rpi4]

  lifecycle {
    # The provider deletes the linked project when destroying its GitOps sync.
    prevent_destroy = true

    precondition {
      condition     = can(regex("^[^/]+/[^/]+$", each.key))
      error_message = "Each application inventory key must use host/app format."
    }

    precondition {
      condition = (
        !contains(["arcane", "portainer"], lower(trimspace(each.value.name))) &&
        !can(regex("(^|/)(arcane|portainer)(/|$)", lower(each.key))) &&
        !can(regex("(^|/)(arcane|portainer)(/|$)", lower(replace(coalesce(each.value.compose_path, "hosts/${each.key}/compose.yml"), "\\", "/"))))
      )
      error_message = "Arcane and Portainer are manually bootstrapped managers; their names and Compose paths must not appear in the application inventory."
    }

    precondition {
      condition = (
        !startswith(coalesce(each.value.compose_path, "hosts/${each.key}/compose.yml"), "/") &&
        !contains(split("/", replace(coalesce(each.value.compose_path, "hosts/${each.key}/compose.yml"), "\\", "/")), "..")
      )
      error_message = "compose_path must be relative to the repository root and must not contain parent-directory segments."
    }

    precondition {
      condition = length(distinct([
        for stack in values(local.gitops_stacks) : "${stack.environment_id}/${stack.name}"
      ])) == length(local.gitops_stacks)
      error_message = "Application names must be unique within each Arcane environment."
    }

    precondition {
      condition     = each.value.sync_interval_minutes >= 1 && floor(each.value.sync_interval_minutes) == each.value.sync_interval_minutes
      error_message = "sync_interval_minutes must be a positive integer."
    }
  }
}
