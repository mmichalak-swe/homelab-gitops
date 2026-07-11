output "id" {
  description = "Portainer stack ID."
  value       = portainer_stack.this.id
}

output "resource_control_id" {
  description = "Portainer resource control ID for the stack."
  value       = portainer_stack.this.resource_control_id
}

output "webhook_url" {
  description = "Portainer stack webhook URL, when stack webhooks are enabled."
  value       = portainer_stack.this.webhook_url
  sensitive   = true
}

