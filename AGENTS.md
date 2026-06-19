# AGENTS.md

## Repository Purpose

This repo is the source of truth for a Docker Compose homelab managed through Portainer, OpenTofu, and Infisical.

Portainer deploys Git-backed stacks from `hosts/<host>/<app>/compose.yml`.
OpenTofu in `opentofu/portainer` manages Portainer objects such as stacks, registries, custom templates, Git settings, and stack environment injection.

## Important Directories

- `hosts/`: per-host Docker Compose stacks.
- `opentofu/portainer/`: OpenTofu root for Portainer-managed resources.
- `opentofu/modules/portainer-stack/`: shared stack module.
- `templates/portainer/`: Portainer custom template sources.
- `Dockerfiles/`: custom image definitions.
- `ansible/`: host bootstrap playbooks.
- `.github/`: Renovate, Trivy, and notification automation.

## Safety Rules

- Do not commit secrets, tokens, API keys, passwords, private endpoints, or real local credentials.
- Do not edit or expose ignored local files such as `*.tfvars`, `*.tfstate`, `.terraform/`, crash logs, or backup state files.
- Treat Infisical as the source of truth for stack secrets.
- Do not run `tofu apply`, `tofu import`, state migration commands, or Portainer-changing commands unless the user explicitly asks.
- Do not change hostnames, stack names, published ports, persistent volume names, static IPs, or network names casually; these may be live infrastructure contracts.
- Preserve existing image digest pins when updating image tags unless the task is specifically about dependency updates.
- Avoid broad refactors. Keep changes scoped to the requested stack, module, or workflow.

## Stack Changes

When adding or changing a Compose stack:

1. Edit the stack file under `hosts/<host>/<app>/compose.yml`.
2. Ensure the matching stack entry exists in `opentofu/portainer/stacks.<host>.tf`.
3. Keep `file_path_in_repository` aligned with the actual Compose path.
4. Use environment variable references for secrets instead of literal secret values.
5. Prefer explicit resource limits, `restart: unless-stopped`, and `security_opt: no-new-privileges:true` when compatible.
6. Be careful with `container_name`; existing stacks use it, so preserve established naming unless intentionally changing it.

## OpenTofu Guidance

Work from `opentofu/portainer` for Portainer infrastructure.

Useful validation commands:

```shell
cd opentofu/portainer
tofu fmt -check -recursive
tofu validate
tofu plan
```

Notes:

- `tofu validate` and `tofu plan` may require local provider configuration and Infisical/Portainer credentials.
- If validation fails because local secrets or provider auth are unavailable, report that clearly instead of inventing values.
- Use `opentofu/portainer/terraform.tfvars.example` for documented variable shape only; do not modify ignored local tfvars files unless explicitly asked.

## Compose Validation

For Compose edits, validate syntax when possible:

```shell
docker compose -f hosts/<host>/<app>/compose.yml config
```

If required environment variables are unavailable locally, report the limitation and still check YAML structure and obvious schema issues.

## Dependency Automation

Renovate watches:

- `.github/**`
- `hosts/*/*/compose.yml`
- `hosts/*/*/compose.yaml`
- `Dockerfiles/*/Dockerfile`
- `opentofu/**/versions.tf`
- `opentofu/**/versions.tofu`

The Caddy stacks under `hosts/**/caddy/**` are intentionally ignored by Renovate. Do not remove that ignore rule unless requested.

Dependency-bot PRs can trigger Trivy scans for changed Compose images. Keep labels and workflow assumptions intact when editing `.github/workflows`.

## Style

- Match the existing formatting in nearby files.
- Use two-space indentation in YAML.
- Use `tofu fmt` formatting for OpenTofu files.
- Prefer small, reviewable changes with clear operational impact.
- Update documentation when changing deployment flow, secret conventions, stack inventory, or validation commands.

## Before Finishing

Summarize:

- Files changed.
- Validation commands run and whether they passed.
- Any commands skipped because they require live credentials or explicit approval.
