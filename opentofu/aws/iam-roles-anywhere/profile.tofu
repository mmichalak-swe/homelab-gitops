resource "aws_rolesanywhere_profile" "role" {
  for_each = var.roles

  name                        = "${each.key}-profile"
  enabled                     = true
  role_arns                   = [aws_iam_role.roles_anywhere[each.key].arn]
  duration_seconds            = var.profile_duration_seconds
  managed_policy_arns         = each.value.profile_managed_policy_arns
  session_policy              = each.value.profile_session_policy_json
  require_instance_properties = false
  accept_role_session_name    = false
}
