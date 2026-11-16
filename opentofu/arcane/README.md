# Arcane on rpi4

Arcane and its LinuxServer socket proxy are bootstrapped manually with
`hosts/6194cicero-raspberrypi/arcane/compose.yml`. The manager and agents remain
outside application GitOps syncs.

Once Arcane is running, this OpenTofu root uses
[HellsCrimson's Arcane provider](https://github.com/HellsCrimson/terraform-provider-arcane/tree/v1.5.0/docs)
to manage:

- Settings for the Pi's built-in local Docker environment (`0`).
- Optional GMK environment registration and, once its agent is online, settings.
- `arcane_git_repository.homelab`, shared by application syncs.
- `arcane_gitops_sync.stacks`, one per application in `stacks.<host>.tofu`,
  with environment values read from Infisical.
- `arcane_container_registry.dockerhub`, with registry tokens from Infisical.
- `arcane_template.standard_compose`, the reusable Compose starting point.

All application stacks are now assigned to Arcane, including Caddy and
Pi-hole/Unbound on both hosts. The Pi inventory has seven applications; GMK has
ten syncs including the stopped `volume-backup` experiment. Existing application
settings and resource addresses are preserved during Portainer retirement.
Portainer's managed resources have been removed and its state is empty. See the
[retirement record](../../docs/portainer-retirement.md) for final host cleanup.

For a fresh manager/agent bootstrap, temporarily omit application entries until
their environments are ready. Environment-wide automatic image checks,
installation, healing, pruning and image patching remain disabled. Git polling
is configured separately per sync. The existing Renovate rule covers
`versions.tofu`.

The Arcane provider is pinned to `1.5.0` from the Terraform Registry, which
OpenTofu supports. The OpenTofu registry mirror rejects this release's signing
key; the Terraform Registry verifies the publisher's signature successfully.

## 1. Prepare the manual bootstrap

Keep the bootstrap Compose checkout outside Arcane's projects directory so
Arcane does not discover its own manager as an application project.

The current Compose file persists `/app/data` in `arcane_data`. Use a projects
path inside that volume, such as `/app/data/projects`, unless deliberately
configuring additional storage. Preserve the existing path and project files
when retiring Portainer. If application bind mounts need files from a host
projects directory, mount that directory into Arcane at the same absolute
path so Docker resolves the same files; do not point it at Portainer's data.

The manager's bootstrap Compose file now defines the Pi's shared `caddy-net`,
preserving the network configuration formerly declared by Portainer. Follow the
[Pi network handover](../../hosts/6194cicero-raspberrypi/README.md) before its first
`up` on the existing host; preserve the live network and its attached services.
On a fresh host, Arcane's bootstrap creates the network. Application stacks
consume it as external. The manager exposes container port `3552` without a
published host port; configure your Caddy route before using its proxied URL.
For a direct LAN trial, the commented `ports` mapping can be enabled
manually and `APP_URL` must match the address used by your browser. The socket
proxy stays on its internal network with no published host port.

Arcane persists its database in the explicitly named `arcane_data` volume.
Back up that volume, the projects directory and the encryption key. Arcane
starts as root to initialize storage, then switches to the configured UID/GID;
setting Compose `user` or dropping all its startup capabilities prevents that
initialization.

## 2. Supply bootstrap values from Infisical and start Compose

Keep the manager's bootstrap environment in Infisical, normally in `prod` at:

```text
/hosts/6194cicero-raspberrypi/arcane
```

| Name | Value |
| --- | --- |
| `APP_URL` | The browser-facing Arcane URL, such as `https://<arcane-hostname>` |
| `ENCRYPTION_KEY` | A persistent random secret, for example from `openssl rand -hex 32` |
| `DOCKER_HOST` | `tcp://arcane-socket-proxy:2375` |
| `PROJECTS_DIRECTORY` | The existing projects path inside persistent storage, normally `/app/data/projects` |
| `PUID` / `PGID` | Runtime UID/GID, normally `1000` / `1000` |
| `TZ` | `America/New_York`, or your desired timezone |

Keep `ENCRYPTION_KEY` stable across upgrades; Arcane needs it to decrypt stored
credentials. Supply these values through your normal Infisical export or
injection workflow. The OpenTofu root does not deploy or inject secrets into the
manager: it needs the manager to be running first.

For example, with those values exported as a protected Docker Compose env file
outside the checkout at `/etc/arcane/bootstrap.env`, run on the Pi from the
repository root:

```shell
docker --host unix:///var/run/docker.sock compose --env-file /etc/arcane/bootstrap.env -p arcane -f hosts/6194cicero-raspberrypi/arcane/compose.yml config --quiet
docker --host unix:///var/run/docker.sock compose --env-file /etc/arcane/bootstrap.env -p arcane -f hosts/6194cicero-raspberrypi/arcane/compose.yml up -d
docker --host unix:///var/run/docker.sock compose --env-file /etc/arcane/bootstrap.env -p arcane -f hosts/6194cicero-raspberrypi/arcane/compose.yml ps
```

Restrict access to that file and never commit it. The explicit Docker socket
selects the Pi's daemon even if the shell also contains the container's
`DOCKER_HOST` value. Wait for both services to be healthy, complete Arcane's
first-login setup, then create an API key for OpenTofu in the UI.

Future manager upgrades use the same manual Compose workflow, including a
`pull` before `up -d`. Do not add a GitOps sync for the manager itself.

## 3. Configure the Arcane OpenTofu root

Create `/opentofu/arcane` in the selected Infisical environment:

| Name | Value |
| --- | --- |
| `arcane_endpoint` | The reachable Arcane API URL ending in `/api`, such as `https://<arcane-hostname>/api` |
| `arcane_api_key` | The API key created in Arcane's UI |
| `git_token` | Only for a private repository with `repository_auth_type = "token"` |
| `git_ssh_key` | Only for a private repository with `repository_auth_type = "ssh"` |
| `gmk_agent_api_url` | GMK agent origin, e.g. `http://<gmk-lan-ip>:3553`, when registering GMK |

Grant the OpenTofu Infisical identity read access to this folder and the
application folders selected below. Bootstrap-time access to the manager's
folder is separate from these provider reads.

From the repository root, create an ignored local configuration from the
example, then set the repository URL, Infisical project ID and authentication:

```shell
cp opentofu/arcane/terraform.tfvars.example opentofu/arcane/local.auto.tfvars
chmod 600 opentofu/arcane/local.auto.tfvars
just fmt
just init arcane
just validate arcane
just plan arcane
```

With both host inventories empty, `gitops_stacks = {}` and
`dockerhub_registries = {}`, a new state should plan only `arcane_settings.rpi4`,
`arcane_git_repository.homelab` and `arcane_template.standard_compose`. Review the plan,
then run `just apply arcane` when ready. The root does not create or restart
the manager, socket proxy or existing applications. If the repository was
already created in the UI, import it before applying rather than creating a
duplicate.

This root uses the shared S3 backend with its own state key,
`arcane/terraform.tfstate`. The AWS identity needs access to that object and
`arcane/terraform.tfstate.tflock`, plus the backend's bucket listing permissions.

The provider uses write-only Git credential arguments. Increment
`repository_credential_version` when rotating a Git token or SSH key. Infisical
data sources still retain their fetched values in state; application environment
values also reach Arcane's project files. Protect state and Arcane backups.

## 4. Opt applications into Git updates

For GMK, first follow the [agent bootstrap guide](../../hosts/6194cicero-gmk-g3/arcane-agent/README.md).
OpenTofu registers its environment and generates a pairing token; its Compose
agent and socket proxy are started manually. `gmk_environment_enabled` enables
registration; `gmk_settings_enabled` enables remote settings after it is online.
Both default to false, and agent bootstrap leaves existing applications alone.

Set the final `gmk_agent_api_url` before registration and keep it stable.
The agent's pairing token stays in its Infisical bootstrap folder as `AGENT_TOKEN`.
This root does not re-send that token for later URL changes. If Infisical's URL
was entered incorrectly after registration, restore the working URL shown in
Arcane before applying the agent settings.

Maintain application definitions in the corresponding committed host inventory:

- `stacks.6194cicero-raspberrypi.tofu` contains seven applications targeting the
  manager's local environment (`0`).
- `stacks.6194cicero-gmk-g3.tofu` contains ten syncs referencing the managed GMK
  environment ID, including the stopped backup experiment.

`stacks.tofu` merges both inventories and supplies defaults. Keys use the
existing `host/app` convention, and `name` must preserve the actual Docker
Compose project name. Caddy and Pi-hole on both hosts are included. The manager
and agent remain outside application inventories.

Keep provider authentication and `repository_branch` in your ignored local
configuration. The existing `gitops_stacks` variable remains supported for
additional entries or full-entry overrides: a matching key replaces the host
file's entry, including its options. Normally keep this map empty and edit the
host files. Existing resource addresses and Infisical paths are unchanged when
moving an entry to a host file with the same key and values.

`compose_path` defaults to `hosts/<map-key>/compose.yml`. Override it when the
existing key differs from its directory, for example
`hosts/6194cicero-raspberrypi/wireguard/compose.yml` for the `wireguard-ls` key.
`branch` overrides `repository_branch` for an individual app; use `add-arcane`
while testing files that have been pushed to that branch. Arcane branch names
do not use Portainer's `refs/heads/` prefix.

Syncs copy the Compose directory by default (`sync_directory = true`), so
adjacent configuration files are available. Every selected application reads
Infisical from `/hosts/<map-key>` in `infisical_env_slug` unless
`infisical_enabled = false`. Per-application `infisical_folder_path` and
`infisical_env_slug` overrides preserve existing secret layouts. Infisical
values override matching optional `stack_env` values, and the resulting map is
passed to the provider's `environment_variables` argument. Docker secrets that
reference files still require those files or volumes to be present.

For another host, register its Arcane environment and bootstrap an agent first;
use that environment's ID instead of `0`. This root registers GMK but does not
install agent containers.

### Git sync and deployment behavior

Creating a GitOps sync performs an initial sync even with `auto_sync = false`.
Changed files can redeploy an already-running project. `start_project = false`
only skips the provider's additional create-time deployment; changing it later
does not start an existing project's containers.

Git polling defaults to hourly. `sync_interval_minutes` is in minutes despite
the pinned provider's generated documentation describing seconds. Changed
running projects are redeployed; `redeploy_after_sync = true` also starts
stopped projects after a change. Leave it false when stopped projects should
remain stopped.

If an Arcane GitOps sync already exists outside state, reconcile/import that
sync using `<environment-id>:<sync-id>` instead of creating another owner.
Provider 1.5.0 cannot adopt a project solely by matching its name. Do not manage
the same project's files with both `arcane_project` and this sync resource.
See the [Git Sync documentation](https://getarcane.app/docs/docker/git-sync)
and [pinned provider implementation](https://github.com/HellsCrimson/terraform-provider-arcane/blob/v1.5.0/internal/provider/resource_gitops_sync.go).

Infisical changes require an OpenTofu apply to update the stored project
environment, followed by a controlled redeployment to refresh running containers.
Git polling alone does not fetch new Infisical values. The provider writes
application environment values after creating the sync, so verify that the
first sync succeeded and all values are present before starting a new project.

The sync resource has `prevent_destroy = true`: the provider's delete operation
also destroys its associated project, even though it retains volumes and files.
Do not treat removing a sync as harmless cleanup. Removing the entire resource
block also removes this lifecycle guard. Keep each application under one
manager and one OpenTofu resource owner throughout handover.

### Image-update policy in OpenTofu

Automatic image checks and installation are disabled through the existing
`arcane_settings.rpi4` and `arcane_settings.gmk` resources:

```hcl
auto_update                 = "false"
polling_enabled             = "false"
image_event_watcher_enabled = "false"
```

This applies to each entire environment, including future applications. Keep
GMK's settings enabled after bootstrap. No Compose extension or additional
settings resource is needed; use `just plan arcane` and `just apply arcane` to
manage this policy through OpenTofu.

`polling_enabled` controls the Automations page's **Image Update Watcher**
toggle and its scheduled registry checks. `image_event_watcher_enabled` disables
additional checks triggered by Docker image events. `auto_update` controls
automatic installation separately; disabling it alone leaves the watcher on.
These settings do not disable application Git polling, manual image checks or
Arcane's own release notification.

Provider 1.5.0 has no project-level automatic-image-update argument. If automatic
updates are later enabled for an environment, selected containers can instead
be excluded in that environment's existing settings resource:

```hcl
auto_update_excluded_containers = "pairdrop"
```

The value is a comma-separated list of actual Docker container names. To exclude
a whole multi-service project, list every container belonging to it; the setting
does not accept a Compose project name as a group selector. PairDrop's container
name happens to equal its project name. Preserve other exclusions when editing
the list. Exclusions are unnecessary while `auto_update = "false"`.

This policy disables automatic image checks and installation, while `auto_sync = true`
still polls Git and deploys changed files for a running project. That preserves
the Renovate workflow: review and merge an image change in Git, then let Arcane
deploy it. To stop scheduled Git deployments too, set that application's
`auto_sync = false` in its host inventory and apply the Arcane root. Setting
`redeploy_after_sync = false` alone does not stop redeployment of a changed,
running project. Manual deployment/update actions remain separate controls.

See the [provider's settings resource](https://github.com/HellsCrimson/terraform-provider-arcane/blob/v1.5.0/docs/resources/arcane_settings.md)
and [Arcane settings reference](https://getarcane.app/docs/reference/environment-variables#settings-overrides).

## 5. Registries and the reusable template

Both registry entries and the reusable template have migrated to Arcane:

- `arcane_container_registry.dockerhub["dockerhub_personal"]`
- `arcane_container_registry.dockerhub["dockerhub_dhi"]`
- `arcane_template.standard_compose`

Maintain registry names, URLs and usernames in `dockerhub_registries` in your
ignored local inputs. Tokens stay in Infisical at
`/opentofu/arcane/dockerhub-registry-tokens`, named `dockerhub_personal` and
`dockerhub_dhi`, using this root's project and `infisical_env_slug`. A different
folder can be set with `infisical_dockerhub_registry_tokens_path`. The map
defaults to empty, so preserve your existing entries after migration.

Registry resources belong to the manager, with no per-environment copies.
Arcane queues synchronization to remote environments when registries change.
Keep GMK online and verify authenticated pulls on both hosts after a credential
change. Registry authentication does not enable automatic image updates.

Tokens use `token_wo`; increment the entry's `credential_version` when rotating
its token or changing its URL, so Arcane receives the credential again.
Infisical data sources still store fetched secrets in state even though this
resource argument is write-only. `repository_names` defaults to an empty list;
include any names you want to retain when importing an existing Arcane registry.
Imports use the object's Arcane ID, never an ID from the former manager.

The template reads `templates/arcane/standard-compose.yml` with `file()`,
preserving Compose's `${UID}` and `${GID}` references. Its environment example
supplies sample IDs. This is an editable starting point with placeholders,
not a deployable application; customize the placeholders and service options
before use. Registering it creates no project. Template file edits reach Arcane
through an OpenTofu apply.

Run `just plan arcane` and `just apply arcane` for future changes. Keep the
existing resource addresses and registry map keys stable.

References: [registry resource](https://github.com/HellsCrimson/terraform-provider-arcane/blob/v1.5.0/docs/resources/arcane_container_registry.md),
[template resource](https://github.com/HellsCrimson/terraform-provider-arcane/blob/v1.5.0/docs/resources/arcane_template.md),
[Arcane registry synchronization](https://github.com/getarcaneapp/arcane/blob/v2.17.3/backend/internal/registry/handler.go).

## Portainer retirement

The Portainer OpenTofu root and bootstrap files are removed, and its managed
resources have been destroyed. Follow the
[remaining host/access cleanup](../../docs/portainer-retirement.md) to remove
its containers while preserving the Pi's shared network. Arcane always reads
its normal API endpoint and credentials from Infisical.

## WireGuard first-sync recovery

An initial WireGuard sync can fail with:

```text
invalid compose file: load compose project: invalid hostPort: /placeholder-undefined
```

Arcane validates the Git files before the provider writes Infisical values into
the newly created project. Its lenient Compose loader substitutes
`/placeholder-undefined` for an unset `${SERVERPORT}`. The short port form
`${SERVERPORT}:51820/udp` rejects that placeholder. WireGuard now uses long port
syntax with `target: 51820`, a required `SERVERPORT` reference in `published`,
and `protocol: udp`. The actual published port still comes from Infisical; no
fallback port is added. The required reference rejects a missing or empty port
during deployment instead of allowing Docker to allocate a random host port.
Arcane's lenient first-sync validation tolerates required references; a
successful Git sync alone does not prove that the environment was injected.
See the [Arcane loader](https://github.com/getarcaneapp/arcane/blob/v2.17.3/backend/pkg/projects/load.go)
and [provider create/update behavior](https://github.com/HellsCrimson/terraform-provider-arcane/blob/v1.5.0/internal/provider/resource_gitops_sync.go).

For a sync that already exists after the failed first attempt:

1. Keep WireGuard's `auto_sync = false` and the project stopped. Confirm its
   old Portainer containers are removed before the first successful sync. Push
   the Compose fix to the branch selected by the existing WireGuard Git sync;
   local edits alone are not visible to Arcane.
2. Use **Sync now** on the existing `wireguard-ls` Git sync. Confirm it succeeds
   and links a stopped project. Do not create another sync or replace/import
   the current OpenTofu resource solely to retry synchronization.
3. Re-send the Infisical environment before starting the project. Provider
   1.5.0 may already have recorded the intended environment map in state even
   though the initial sync never created a project to receive it. Refresh does
   not read back that map, and an unchanged apply will not re-send it.

   First inspect the existing project's environment in Arcane locally, without
   copying secret values into logs. Confirm that the source folder is
   `/hosts/6194cicero-raspberrypi/wireguard-ls` in the selected Infisical
   environment (or its configured path override), even though the Compose
   directory is named `wireguard`.

   If the project environment is empty, a clean plan does not establish that
   the values reached Arcane. With provider 1.5.0, unchanged applies, refreshes
   and Git syncs do not repair this state discrepancy. Restore the real values
   from that Infisical folder into the existing project's environment using a
   protected export and Arcane's environment editor, or address the provider's
   reconciliation behavior before relying on an apply to repair it. Keep
   Infisical as the source of truth; do not add dummy refresh variables or
   replace the GitOps resource just to force an update. This manual restore is
   a one-time recovery, not a replacement for OpenTofu's normal secret updates.

   If the project already has the correct values, recreate the container from
   that project rather than changing Infisical or OpenTofu state. A plain
   container restart does not reload its environment or change its port binding.
4. Verify the project's environment contains the real `SERVERPORT` and the
   other WireGuard values from Infisical, then deploy/start it in Arcane.
   `start_project = true` is a create-time provider action; it does not start
   an already-existing sync after this repair. Check the published UDP port,
   retained `wireguard-ls_config` volume, health and an existing peer connection.
5. Once verified, set WireGuard's `auto_sync = true` in its Arcane host inventory
   and run `just plan arcane` / `just apply arcane` to enable hourly Git polling.

## Validation without live credentials

With a fresh temporary `TF_DATA_DIR`, initialize using
`TF_CLI_ARGS_init=-backend=false just init arcane`, then use the same data
directory for `just validate arcane`. This downloads providers without opening
the S3 backend. `just plan arcane` requires backend credentials, Infisical
credentials and a reachable Arcane API.

See the upstream [installation guide](https://getarcane.app/docs/get-started/installation),
[projects guide](https://getarcane.app/docs/docker/projects) and
[socket proxy guide](https://getarcane.app/docs/security/socket-proxy).
The socket proxy uses the pinned LinuxServer image, matching the homelab's proxy pattern,
with a read-only filesystem and writable `/run` tmpfs. Its switches enable Docker
mutations needed for Compose management; this is not a read-only Docker connection.
