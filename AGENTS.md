# AGENTS.md

## Repository Purpose

This repo is the source of truth for a Docker Compose homelab managed through Arcane, OpenTofu, and Infisical.

Arcane deploys Git-backed projects from `hosts/<host>/<app>/compose.yml`.
All applications, including Caddy and Pi-hole on both hosts, have migrated.
Portainer's managed resources have been destroyed and its state is empty.
Its OpenTofu root, module, template and bootstrap Compose file are removed.
Remaining host teardown and access cleanup are documented in
`docs/portainer-retirement.md`; do not recreate Portainer resources.
Arcane itself is bootstrapped manually with Docker Compose.
Do not register Arcane as an application GitOps project.
Arcane agents are also manually bootstrapped; keep them out of application inventories.
`opentofu/arcane` manages Arcane settings, the Git repository and explicitly
selected application GitOps syncs, with secrets from Infisical.
It also manages container registry credentials and the reusable Compose template
under `templates/arcane`; keep registry tokens in Infisical.
It also manages the optional GMK environment registration and, after the agent
is online, its settings.
The Pi's Arcane bootstrap owns the shared `caddy-net` definition; all Pi
applications consume it as external.
Preserve the live network during adoption. GMK Caddy still owns its own network.

## Important Directories

- `hosts/`: per-host Docker Compose stacks.
- `opentofu/aws/iam-roles-anywhere/`: IAM Roles Anywhere trust anchor, profiles, and roles.
- `opentofu/bootstrap/state-backend/`: shared S3 state-bucket ownership and settings.
- `opentofu/backends/`: committed, non-secret partial backend configuration.
- `opentofu/arcane/`: OpenTofu root for Arcane-managed application resources.
- `templates/arcane/`: active reusable Compose template source.
- `docs/portainer-retirement.md`: completed state cleanup and remaining host teardown.
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
2. Ensure the matching application entry exists in `opentofu/arcane/stacks.<host>.tofu`. Manually bootstrapped managers and agents are exceptions. Do not add applications back to the retired Portainer inventories. Keep secrets in Infisical, not the committed inventories.
3. Keep `compose_path` aligned with the actual Compose path.
4. Use environment variable references for secrets instead of literal secret values.
5. Prefer explicit resource limits, `restart: unless-stopped`, and `security_opt: no-new-privileges:true` when compatible.
6. Be careful with `container_name`; existing stacks use it, so preserve established naming unless intentionally changing it.

## OpenTofu Guidance

Run the repository `Justfile` from the repository root. Initialize a root before
validating or planning it.

Useful validation commands:

```shell
just fmt
just init arcane
just validate arcane
just plan arcane
```

Notes:

- `just validate` and `just plan` may require local provider configuration and Infisical/Arcane credentials.
- `just fmt` checks tracked and unignored OpenTofu files without reading ignored local tfvars.
- If validation fails because local secrets or provider auth are unavailable, report that clearly instead of inventing values.
- Use `opentofu/arcane/terraform.tfvars.example` for documented variable shape only; do not modify ignored local tfvars files unless explicitly asked.

## Compose Validation

For Compose edits, validate syntax when possible:

```shell
docker compose -f hosts/<host>/<app>/compose.yml config
```

If required environment variables are unavailable locally, report the limitation and still check YAML structure and obvious schema issues.

## Dependency Automation

Renovate watches:

- `.github/workflows/**`
- `hosts/*/*/compose.yml`
- `Dockerfiles/*/Dockerfile`
- `opentofu/**/versions.tofu`

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
