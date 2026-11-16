# Arcane agent on GMK

OpenTofu manages GMK's registration in the Arcane manager and its automation
settings. The agent container and its LinuxServer socket proxy are bootstrapped
manually with this Compose file, matching the manager's deployment model. Do not
add either service to an Arcane application GitOps sync.

The HellsCrimson provider manages the `arcane_environment` API object; it does
not install the agent container on a host. Fully automating that installation
would require a separate Docker-provider or Ansible bootstrap workflow.

This configuration uses Direct mode. The Pi manager must reach GMK on TCP
`3553`, and the agent must reach the manager's browser-facing URL. The agent's
port binds only to the LAN address supplied through `AGENT_BIND_IP`; the Docker
socket proxy has no host port. Keep access to the agent port on your trusted
LAN/VPN. No existing application networks or static IPs are changed.

The agent is pinned to `v2.16.1`, matching the manager version in this repo.
Confirm that your running manager uses that release before starting the agent.
The proxy uses GMK Beszel's existing LinuxServer image pin.

## 1. Register GMK with OpenTofu

Keep both Arcane application inventories empty during a fresh bootstrap.
Temporarily comment out application entries, including PairDrop, until the
agent is online and their handover is prepared.

In Infisical's `/opentofu/arcane` folder, add `gmk_agent_api_url` with the
manager-reachable agent origin, for example `http://<gmk-lan-ip>:3553`. Unlike
the manager's `arcane_endpoint`, this value must not end in `/api`.
Choose the final address before creating the environment and keep it stable;
this configuration does not manage the token re-entry required for URL changes.

In your ignored Arcane local configuration, set:

```hcl
gmk_environment_enabled = true
gmk_settings_enabled    = false
```

From the repository root on your workstation:

```shell
just init arcane
just validate arcane
just plan arcane
just apply arcane
```

Review the plan first. If the base setup is already applied, the only new
resource should be `arcane_environment.gmk[0]`. Otherwise, the manager settings
and Git repository may also be created. No applications should be deployed.
The environment can remain pending/offline until its agent starts. Its
`prevent_destroy` guard prevents accidentally removing the registration through
a normal configuration change.

If GMK was already registered manually, import that environment before applying
instead of creating a duplicate:

```shell
tofu -chdir=opentofu/arcane import 'arcane_environment.gmk[0]' '<existing-environment-id>'
```

The generated token is returned only on creation. For an imported environment,
use the existing agent token or regenerate it deliberately in the manager UI.

## 2. Store the pairing token and bootstrap values in Infisical

After creating the environment, read its initial token locally:

```shell
tofu -chdir=opentofu/arcane output -raw gmk_agent_pairing_token
```

This command intentionally displays a secret. Store it as `AGENT_TOKEN` in
Infisical at `/hosts/6194cicero-gmk-g3/arcane-agent`, normally in `prod`. Do not
commit it or paste it into task logs. The normal OpenTofu output hides it, but
it is retained in the Arcane S3 state. Bootstrap consumes the copy in Infisical.

Populate the same folder with:

| Variable | Value |
| --- | --- |
| `AGENT_TOKEN` | The generated pairing token above; not the OpenTofu manager API key |
| `MANAGER_API_URL` | Manager URL reachable from GMK, e.g. `https://<arcane-hostname>`, without `/api` |
| `AGENT_BIND_IP` | GMK's LAN IP; must match the host used in `gmk_agent_api_url` |
| `ENCRYPTION_KEY` | A stable, separate agent encryption key; generate with `openssl rand -hex 32` |
| `PROJECTS_DIRECTORY` | Optional; defaults to `/opt/arcane/projects` |
| `PUID` / `PGID` | Optional; both default to `1000` |
| `TZ` | Optional; defaults to `America/New_York` |

Export this folder as a protected Docker Compose dotenv file on GMK, outside the
repository, using your normal Infisical export/injection workflow. The commands
below assume `/etc/arcane/agent.env`, readable only by the account performing
bootstrap. Keep the encryption key stable and back it up with `arcane_agent_data`
and the projects directory.

Pairing-token rotation requires updating the token on both sides and restarting
the agent. The provider's initial-token output does not track a token regenerated
in the UI; use the newly generated value for Infisical. Do not leave
`regenerate_api_key` enabled as a standing configuration.

## 3. Start the agent on GMK

Copy or pull this repository onto GMK outside `/opt/arcane/projects`. The agent
must not discover its own bootstrap Compose file as an application project.
Verify port `3553` is available, and ensure the manager's address resolves and
is reachable from GMK.

On GMK, create the projects directory using the configured UID/GID:

```shell
sudo install -d -o 1000 -g 1000 -m 0750 /opt/arcane/projects
```

The directory is mounted at the same absolute path on the host and in the
container so future application bind mounts resolve correctly. Adjust the path
and ownership if you change `PROJECTS_DIRECTORY`, `PUID` or `PGID`.

From the repository root on GMK:

```shell
docker --host unix:///var/run/docker.sock compose --env-file /etc/arcane/agent.env -p arcane-agent -f hosts/6194cicero-gmk-g3/arcane-agent/compose.yml config --quiet
docker --host unix:///var/run/docker.sock compose --env-file /etc/arcane/agent.env -p arcane-agent -f hosts/6194cicero-gmk-g3/arcane-agent/compose.yml pull
docker --host unix:///var/run/docker.sock compose --env-file /etc/arcane/agent.env -p arcane-agent -f hosts/6194cicero-gmk-g3/arcane-agent/compose.yml up -d
docker --host unix:///var/run/docker.sock compose --env-file /etc/arcane/agent.env -p arcane-agent -f hosts/6194cicero-gmk-g3/arcane-agent/compose.yml ps
```

The agent starts as root for storage setup, then switches to the configured
UID/GID. Its socket access is through the proxy; it does not mount Docker's
socket directly. The proxy has a read-only filesystem and writable `/run`.

Wait for both containers to become healthy. In the Arcane UI, confirm GMK is
online and that its container list shows GMK's existing applications. Seeing
PairDrop there does not migrate its Compose source or resource ownership.

For troubleshooting on GMK:

```shell
docker logs --tail 100 arcane-agent
docker logs --tail 100 arcane-agent-socket-proxy
docker inspect arcane-agent --format '{{.State.Health.Status}}'
```

## 4. Apply the remote environment's settings

Once the agent is reachable, set this in the workstation's ignored local
configuration, keeping `gmk_environment_enabled = true`:

```hcl
gmk_settings_enabled = true
```

Then run from the repository root on your workstation:

```shell
just plan arcane
just apply arcane
tofu -chdir=opentofu/arcane output -raw gmk_environment_id
```

The new resource should be `arcane_settings.gmk[0]`. It disables automatic
image checks and updates, healing, pruning, image patching and vulnerability
scanning on GMK.
This separate step is necessary because settings requests are sent to the
running agent; initial environment registration does not require it to exist.
Keep both flags enabled after setup.

If an apply fails with `Changing environment API URL requires re-entering the
accessToken`, compare Infisical's `gmk_agent_api_url` with GMK's API URL in the
Arcane UI. The plan redacts the URL because it comes from Infisical. If the
change was unintended, correct the Infisical value to match the working URL
and run a new plan. When the URL matches, the existing registration and running
agent can be kept; no token regeneration or state removal is needed. An
intentional URL change requires a separate, deliberate connection update.

### One-time recreation during bootstrap

This historical recovery applies only to an empty environment during initial
bootstrap. GMK now has migrated applications; do not use this reset to retire
the former manager or change the working agent connection.

If the registered URL is wrong and the Infisical URL is correct, recreate only
GMK's environment before migrating applications. Confirm GMK has no Arcane
GitOps syncs, including any created manually: deleting an environment also
removes its sync registrations. Use this only before assigning any applications
to this environment.

1. Set the correct `gmk_agent_api_url` in Infisical's `/opentofu/arcane` folder.
   In the workstation's ignored local configuration, keep
   `gmk_environment_enabled = true` and set `gmk_settings_enabled = false`.
   This procedure assumes the failed settings apply never created
   `arcane_settings.gmk[0]`.
2. On GMK, stop only the agent while replacing its registration:

   ```shell
   docker --host unix:///var/run/docker.sock stop arcane-agent
   ```

3. In Arcane's Environments page, delete only `6194cicero-gmk-g3`. Keep the Pi
   environment, manager, Git repository, Docker volumes and application
   containers. The provider detects the missing registration on refresh;
   do not remove its OpenTofu state entry or disable `prevent_destroy`.
4. On the workstation, from the repository root:

   ```shell
   just init arcane
   just validate arcane
   just plan arcane
   just apply arcane
   tofu -chdir=opentofu/arcane output -raw gmk_agent_pairing_token
   ```

   With the rest of bootstrap already applied, expect only
   `arcane_environment.gmk[0]` to be created: `1 to add, 0 to change, 0 to destroy`.
   Review any additional changes before proceeding. The replacement has a new
   environment ID and pairing token.
5. Store the new output as `AGENT_TOKEN` in Infisical's
   `/hosts/6194cicero-gmk-g3/arcane-agent` folder. Re-export that folder to
   `/etc/arcane/agent.env` on GMK using the same protected-file workflow as
   bootstrap. Preserve `ENCRYPTION_KEY`, `arcane_agent_data` and project data.
   Confirm `AGENT_BIND_IP` matches the intended GMK LAN address. On GMK, from
   the repository root:

   ```shell
   docker --host unix:///var/run/docker.sock compose --env-file /etc/arcane/agent.env -p arcane-agent -f hosts/6194cicero-gmk-g3/arcane-agent/compose.yml config --quiet
   docker --host unix:///var/run/docker.sock compose --env-file /etc/arcane/agent.env -p arcane-agent -f hosts/6194cicero-gmk-g3/arcane-agent/compose.yml up -d --no-deps --force-recreate arcane-agent
   docker --host unix:///var/run/docker.sock compose --env-file /etc/arcane/agent.env -p arcane-agent -f hosts/6194cicero-gmk-g3/arcane-agent/compose.yml ps
   ```

   The socket proxy stays running. Recreating the agent container loads the new
   token; a plain container restart would retain its old environment variables.
6. Once GMK is healthy and online in Arcane, set `gmk_settings_enabled = true`
   again and run `just plan arcane`, `just apply arcane`, then `just plan arcane`
   on the workstation. The first plan should create only GMK's settings; the
   last should show no changes.

This resets the Arcane connection without redeploying application containers.
Future stacks that reference `arcane_environment.gmk[0].id` automatically use
the new environment ID.

GMK's application definitions reference `arcane_environment.gmk[0].id`
directly. Existing applications have migrated to Arcane; preserve their
environment registration and project identities. See the
[application inventory guide](../../../opentofu/arcane/README.md#4-opt-applications-into-git-updates)
and [Portainer retirement record](../../../docs/portainer-retirement.md).

See the [Arcane remote environments guide](https://getarcane.app/docs/remote/environments)
and the [pinned provider resource](https://github.com/HellsCrimson/terraform-provider-arcane/blob/v1.5.0/docs/resources/arcane_environment.md).
