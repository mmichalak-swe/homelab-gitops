output "stack_ids" {
  description = "Managed Portainer stack IDs."
  value = {
    for key, stack in module.stack : key => stack.id
  }
}

output "stack_webhook_urls" {
  description = "Managed Portainer stack webhook URLs."
  value = {
    for key, stack in module.stack : key => stack.webhook_url
  }
  sensitive = true
}

output "dockerhub_registry_ids" {
  description = "Managed Docker Hub registry IDs."
  value = {
    for key, registry in portainer_registry.dockerhub : key => registry.id
  }
}
