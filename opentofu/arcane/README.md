# Arcane on rpi4

Arcane and its LinuxServer socket proxy are bootstrapped manually with
`hosts/6194cicero-raspberrypi/arcane/compose.yml`, just like Portainer. Neither
manager belongs in the Portainer application inventory or Arcane GitOps syncs.

Once Arcane is running, this OpenTofu root uses
[HellsCrimson's Arcane provider](https://github.com/HellsCrimson/terraform-provider-arcane/tree/v1.5.0/docs)
to manage:

- Settings for the Pi's built-in local Docker environment (`0`).
- `arcane_git_repository.homelab`, shared by application syncs.
- `arcane_gitops_sync.stacks`, one per application in `stacks.<host>.tofu`,
  with environment values read from Infisical.

The default application inventory is empty. Existing Portainer applications
continue running under their current ownership until individually handed over.
Manager-wide automatic updates, healing, pruning, image patching and
vulnerability scanning are disabled; application Git polling is configured
separately for each sync. The existing Renovate rule covers `versions.tofu`.

The Arcane provider is pinned to `1.5.0` from the Terraform Registry, which
OpenTofu supports. The OpenTofu registry mirror rejects this release's signing
key; the Terraform Registry verifies the publisher's signature successfully.

## 1. Prepare the manual bootstrap

Keep the bootstrap Compose checkout outside Arcane's projects directory so
Arcane does not discover its own manager as an application project.

Create a dedicated absolute projects path on the Pi, owned by the runtime
UID/GID you will configure. For example:

```shell
sudo install -d -o 1000 -g 1000 -m 0750 /opt/arcane/projects
```

Set `PROJECTS_DIRECTORY` to that same path. Compose bind-mounts it at the
identical location inside Arcane and requires it to exist. This lets the Docker
daemon resolve application bind mounts to the same files Arcane sees. Do not
point it at Portainer's data directory. If you have already stored projects in
Arcane, preserve and transfer their files before changing the projects path or
adding a mount over it.

The current Compose file joins the existing external `caddy-net` network and
exposes container port `3552`; it does not publish a host port. Ensure that
network exists and configure your Caddy route to Arcane before using its proxied
URL. For a direct LAN trial, the commented `ports` mapping can be enabled
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
| `PROJECTS_DIRECTORY` | The absolute projects path, for example `/opt/arcane/projects` |
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

With both host inventories empty and `gitops_stacks = {}`, a new state should plan only
`arcane_settings.rpi4` and `arcane_git_repository.homelab`. Review the plan,
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

Add applications to the corresponding committed host inventory only after
preparing their ownership handover:

- `stacks.6194cicero-raspberrypi.tofu` contains a commented Homer example.
- `stacks.6194cicero-gmk-g3.tofu` contains a commented PairDrop example. Replace
  its environment ID with the GMK agent's actual Arcane environment ID.

`stacks.tofu` merges both inventories and supplies defaults. Keys use the
existing `host/app` convention, and `name` must preserve the actual Docker
Compose project name. For example, after preparing Homer, its host file becomes:

```hcl
locals {
  stacks_6194cicero_raspberrypi = {
    "6194cicero-raspberrypi/homer" = {
      name                  = "homer"
      environment_id        = "0"
      auto_sync             = false
      sync_interval_minutes = 60
      start_project         = false
      infisical_enabled     = false
    }
  }
}
```

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

For another host, bootstrap an Arcane agent and register its environment first;
use that environment's ID instead of `0`. This root does not install agents.

### Handover and deployment behavior

Both managers can observe running containers. Creating a GitOps sync is an
active operation: Arcane performs an initial sync even with `auto_sync = false`,
and changed files can redeploy an already-running project. `start_project =
false` only skips the provider's additional create-time deployment. It is not a
no-downtime guarantee. See the [Git Sync documentation](https://getarcane.app/docs/docker/git-sync)
and [pinned provider implementation](https://github.com/HellsCrimson/terraform-provider-arcane/blob/v1.5.0/internal/provider/resource_gitops_sync.go).

For an existing Portainer application:

1. Back up its data and record the actual Compose project name, Git revision,
   volumes, networks, bind paths and all injected environment values.
2. Stop Portainer's automatic updates for that application. Deliberately detach
   its OpenTofu ownership while removing its Portainer inventory entry, without
   deleting the running stack. Removing configuration alone plans destruction;
   do not apply that deletion or use Portainer's remove-stack action.
3. Stage the application's Compose/config files and resolved Infisical values
   for Arcane, preserving Docker identities and data paths. Prepare a
   maintenance window for the first sync/deployment.
4. If adopting an existing Arcane project, link it to the repository through
   Arcane's UI/API, then import that sync into
   `arcane_gitops_sync.stacks["<host>/<app>"]` using `<environment-id>:<sync-id>`.
   Provider 1.5.0 cannot accept an existing project ID when creating a sync;
   supplying its name alone is not an adoption mechanism. Do not independently
   manage the same project's files with both `arcane_project` and this sync.
5. Review `just plan arcane`, apply when ready, verify the project files and
   environment, then perform and check its first deployment. For a new stopped
   project, start it explicitly after creation; changing `start_project` later
   does not start an existing sync's project.
6. Set `auto_sync = true` and apply to enable periodic Git updates. The default
   is hourly; `sync_interval_minutes` is in minutes despite the provider's
   generated documentation describing seconds. Changed running projects are
   redeployed. `redeploy_after_sync = true` additionally starts stopped projects
   after a change; leave it false if stopped projects should remain stopped.

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

## Validation without live credentials

With a fresh temporary `TF_DATA_DIR`, initialize using
`TF_CLI_ARGS_init=-backend=false just init arcane`, then use the same data
directory for `just validate arcane`. This downloads providers without opening
the S3 backend. `just plan arcane` requires backend credentials, Infisical
credentials and a reachable Arcane API.

See the upstream [installation guide](https://getarcane.app/docs/get-started/installation),
[projects guide](https://getarcane.app/docs/docker/projects) and
[socket proxy guide](https://getarcane.app/docs/security/socket-proxy).
The socket proxy uses the same pinned LinuxServer image as Portainer and Beszel,
with a read-only filesystem and writable `/run` tmpfs. Its switches enable Docker
mutations needed for Compose management; this is not a read-only Docker connection.
