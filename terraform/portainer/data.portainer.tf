data "portainer_environment" "host" {
  for_each = var.portainer_environment_names

  name = each.value
}
