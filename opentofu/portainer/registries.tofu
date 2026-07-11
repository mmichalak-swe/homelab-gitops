resource "portainer_registry" "dockerhub" {
  for_each = var.dockerhub_registries

  authentication = each.value.authentication
  name           = each.value.name
  password       = local.dockerhub_registry_tokens[each.key]
  type           = each.value.type
  url            = each.value.url
  username       = each.value.username
}
