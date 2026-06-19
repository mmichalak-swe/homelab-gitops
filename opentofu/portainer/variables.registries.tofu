variable "dockerhub_registries" {
  description = "Docker Hub registries to register in Portainer. The map key must also exist in dockerhub_registry_tokens. Use type 6 for Docker Hub."
  type = map(object({
    authentication = bool
    name           = string
    type           = number
    username       = string
    url            = optional(string, "docker.io")
  }))
  default = {}
}

variable "dockerhub_registry_tokens" {
  description = "Docker Hub personal access tokens, keyed by dockerhub_registries key. Infisical values override this map when infisical_dockerhub_registry_tokens_enabled is true."
  type        = map(string)
  default     = {}
  sensitive   = true
}
