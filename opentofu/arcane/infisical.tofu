data "infisical_secrets" "arcane_config" {
  env_slug     = var.infisical_env_slug
  workspace_id = var.infisical_project_id
  folder_path  = var.infisical_arcane_config_path

  lifecycle {
    postcondition {
      condition = try(
        can(regex("^https?://[^/]+(/[^?#]*)?/api/?$", self.secrets["arcane_endpoint"].value)) &&
        trimspace(self.secrets["arcane_api_key"].value) != "",
        false,
      )
      error_message = "The Arcane Infisical folder must contain arcane_endpoint (an HTTP(S) URL ending in /api) and a non-empty arcane_api_key."
    }
  }
}

locals {
  arcane_config = {
    for name, secret in data.infisical_secrets.arcane_config.secrets :
    name => secret.value
  }

  arcane_endpoint = trimsuffix(nonsensitive(local.arcane_config["arcane_endpoint"]), "/")
}
