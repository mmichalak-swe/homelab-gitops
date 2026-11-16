# homelab-gitops

Docker Compose homelab infrastructure managed through Arcane, OpenTofu and
Infisical, including Caddy and Pi-hole/Unbound on both hosts.

## Deployment model

Application Compose files live at `hosts/<host>/<app>/compose.yml`. OpenTofu in
`opentofu/arcane` manages the shared Git repository, per-application GitOps syncs,
environment settings and GMK's environment registration. The host inventories
are `opentofu/arcane/stacks.<host>.tofu`.
The same root manages registry credentials and the reusable Compose template.

Arcane's manager on the Pi and its agent on GMK, each with a LinuxServer socket
proxy, are bootstrapped manually. They must not manage their own Compose files
as application GitOps projects.

Arcane's bootstrap Compose file owns the Pi's shared `caddy-net` definition;
the applications consume it as external.
Preserve the existing network during adoption. GMK Caddy continues to own its
own network.

## Repository structure

| Path | Purpose |
| --- | --- |
| `hosts/` | Per-host Compose files and Docker daemon configuration |
| `opentofu/arcane/` | Active application and environment management |
| `templates/arcane/` | Reusable Compose template managed through OpenTofu |
| `opentofu/aws/iam-roles-anywhere/` | AWS authentication infrastructure |
| `opentofu/bootstrap/state-backend/` | Shared S3 state bucket ownership |
| `opentofu/backends/` | Non-secret partial backend configuration |
| `Dockerfiles/` | Custom image definitions |
| `ansible/` | Host bootstrap playbooks |
| `.github/` | Dependency updates, image scanning and notifications |

## OpenTofu

Install OpenTofu and `just`. Configure AWS access to the shared state bucket and
Infisical authentication through your normal local credential workflow.
Use `opentofu/arcane/terraform.tfvars.example` for the documented input shape;
real local tfvars stay ignored.

Run from the repository root:

```shell
just fmt
just init arcane
just validate arcane
just plan arcane
just apply arcane
```

The generic recipes also accept `aws/iam-roles-anywhere` and
`bootstrap/state-backend`.
All roots use `opentofu/backends/homelab.s3.tfbackend` for the shared bucket and
region, with separate state keys in their own backend blocks. Arcane uses
`arcane/terraform.tfstate`.

The state bucket remains shared infrastructure. Its ownership stays in the
[state-backend root](opentofu/bootstrap/state-backend/README.md). AWS IAM Roles
Anywhere has its own [setup guide](opentofu/aws/iam-roles-anywhere/README.md).

## Secrets and updates

Infisical remains the source of truth:

- `/opentofu/arcane`: Arcane provider credentials, Git credentials and GMK's URL.
- `/opentofu/arcane/dockerhub-registry-tokens`: registry tokens keyed by registry name.
- `/hosts/<host>/<app>`: application environment values.
- The manager and agent bootstrap folders under `/hosts`: values supplied
  separately before running OpenTofu.

Infisical changes require an OpenTofu apply and a controlled project deployment
to refresh running containers. Git polling does not fetch updated secrets.
Environment-wide automatic image updates and watchers are disabled; per-project
Git polling follows the host inventories. Renovate continues to propose pinned
image changes through Git. The `volume-backup` experiment remains stopped.

State and Arcane project files contain secrets. Protect their storage and
backups; never commit credentials or generated environment files.
