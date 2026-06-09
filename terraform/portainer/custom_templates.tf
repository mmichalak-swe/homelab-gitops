resource "portainer_custom_template" "standard_compose" {
  title       = "standard-docker-compose"
  description = "Standard docker compose template, caddy-net network, numerous placeholders"
  note        = "Managed by Terraform"

  platform = 1 # Linux
  type     = 2 # Compose

  repository_url       = "https://github.com/mmichalak-swe/homelab-gitops"
  repository_reference = "refs/heads/main"
  compose_file_path    = "templates/portainer/standard-compose.yml"

  tlsskip_verify = false
}
