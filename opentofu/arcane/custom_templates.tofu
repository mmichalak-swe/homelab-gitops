resource "arcane_template" "standard_compose" {
  name        = "standard-docker-compose"
  description = "Standard docker compose template, caddy-net network, numerous placeholders"
  content     = file("${path.module}/../../templates/arcane/standard-compose.yml")
  env_content = <<-EOT
    # Example IDs; customize these and the Compose placeholders before deployment.
    UID=1000
    GID=1000
  EOT
}
