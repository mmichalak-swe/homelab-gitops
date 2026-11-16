variable "dockerhub_registries" {
  description = "Registry credentials to register in Arcane. Infisical token names must match these map keys. Supply registry names, URLs and usernames here; tokens stay in Infisical."
  type = map(object({
    name               = string
    url                = string
    username           = string
    credential_version = optional(number, 1)
    repository_names   = optional(list(string), [])
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for registry in values(var.dockerhub_registries) :
      trimspace(registry.name) != "" && trimspace(registry.url) != "" && trimspace(registry.username) != ""
    ])
    error_message = "Every registry must have a non-empty name, URL and username."
  }

  validation {
    condition = alltrue([
      for registry in values(var.dockerhub_registries) :
      registry.credential_version >= 1 && floor(registry.credential_version) == registry.credential_version
    ])
    error_message = "Each registry credential_version must be a positive integer. Increment it when changing its token or URL."
  }
}

variable "infisical_dockerhub_registry_tokens_path" {
  description = "Infisical folder containing registry tokens, keyed by dockerhub_registries. Uses the Arcane root's Infisical project and environment."
  type        = string
  default     = "/opentofu/arcane/dockerhub-registry-tokens"
  nullable    = false
}
