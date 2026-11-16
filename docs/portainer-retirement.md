# Portainer retirement

## Completed

Applications, both registry entries and the reusable template are managed by
Arcane. A reviewed destroy plan removed exactly:

- `portainer_custom_template.standard_compose`
- `portainer_registry.dockerhub["dockerhub_dhi"]`
- `portainer_registry.dockerhub["dockerhub_personal"]`

A subsequent state read verified **zero resource instances**, including data
sources, in `portainer/terraform.tfstate`. State/plan backups and the removed
configuration were preserved privately outside the checkout. No application
stacks or Arcane resources were part of this plan.

The repository no longer contains the Portainer OpenTofu root, shared module,
template or bootstrap Compose file. Ignored local credentials and caches were
not deleted. Never run a normal apply using an old Portainer checkout: it would
recreate the retired objects.

The shared S3 bucket remains in use by Arcane and both AWS roots, despite its
legacy name. Preserve its configuration, active state keys, the empty retired
state object and protected version history. No bucket deletion or state
migration is needed.

## Remaining: Pi containers and private network

The live host teardown was **not executed**: SSH access was declined. Run the
following on the Pi after reviewing it. Do not use an old Portainer Compose
file with `compose down`; it may declare `caddy-net` as managed.

The Pi's [Arcane bootstrap](../hosts/6194cicero-raspberrypi/arcane/compose.yml)
defines `caddy-net` with its existing IPAM. Keep this live network and its
attached application containers. Historical Portainer labels can remain; see
the [network adoption guide](../hosts/6194cicero-raspberrypi/README.md). Removing
those labels is not a reason to recreate the network.

This script verifies the Portainer project contains only its two bootstrap
containers, records the live network ID and data volume, stops Portainer for a
consistent backup, and removes those containers and their private proxy network.
It does not remove volumes, images, `caddy-net`, or application containers.
It stops on any unexpected layout. If one of the containers is already gone,
inspect what remains instead of substituting another container or project.

```shell
bash <<'SH'
set -euo pipefail
umask 077
d() { docker --host unix:///var/run/docker.sock "$@"; }

portainer_project=$(d inspect portainer --format '{{index .Config.Labels "com.docker.compose.project"}}')
portainer_volume=$(d inspect portainer --format '{{range .Mounts}}{{if eq .Destination "/data"}}{{.Name}}{{end}}{{end}}')
caddy_network_id=$(d network inspect caddy-net --format '{{.Id}}')
test -n "$portainer_project"
test "$portainer_project" != '<no value>'
test -n "$portainer_volume"
test -n "$caddy_network_id"
test "$(d inspect portainer-socket-proxy --format '{{index .Config.Labels "com.docker.compose.project"}}')" = "$portainer_project"
test "$(d ps -a --filter "label=com.docker.compose.project=$portainer_project" --format '{{.Names}}' | sort)" = "$(printf '%s\n' portainer portainer-socket-proxy | sort)"
test "$(d ps -a --filter "volume=$portainer_volume" --format '{{.Names}}')" = portainer

backup_dir=$(mktemp -d /var/tmp/portainer-retired.XXXXXX)
mkdir "$backup_dir/data"
printf '%s\n' "$portainer_volume" > "$backup_dir/volume-name.txt"
printf '%s\n' "$caddy_network_id" > "$backup_dir/caddy-network-id.txt"
d network inspect caddy-net > "$backup_dir/caddy-network-before.json"
d ps --format 'table {{.Names}}\t{{.Status}}'

d stop portainer
d cp portainer:/data/. "$backup_dir/data/"
test -n "$(ls -A "$backup_dir/data")"
d stop portainer-socket-proxy
d rm portainer portainer-socket-proxy

if d network inspect portainer_sp_net >/dev/null 2>&1; then
  test "$(d network inspect portainer_sp_net --format '{{index .Labels "com.docker.compose.project"}}')" = "$portainer_project"
  test "$(d network inspect portainer_sp_net --format '{{len .Containers}}')" = 0
  d network rm portainer_sp_net
fi

test "$caddy_network_id" = "$(d network inspect caddy-net --format '{{.Id}}')"
d network inspect caddy-net > "$backup_dir/caddy-network-after.json"
d volume inspect "$portainer_volume" --format '{{.Name}}'
d ps --format 'table {{.Names}}\t{{.Status}}'
printf 'Portainer containers removed; caddy-net ID unchanged. Private backup: %s\n' "$backup_dir"
printf 'Retained Portainer volume: %s\n' "$portainer_volume"
SH
```

Verify Arcane, Caddy HTTPS routes, DNS/Pi-hole, WireGuard and the GMK agent. From
the workstation, run `just plan arcane` using your normal AWS/Infisical access.
No Arcane resource changes should be needed for Portainer removal.

After those checks and preserving the backup in protected storage, the old
Portainer volume can also be removed. Use the **exact volume name printed by
the script**, confirm `docker ps -a --filter volume=VOLUME_NAME` has no users,
then run `docker volume rm VOLUME_NAME` against the Pi's local daemon. Do not
remove `arcane_data`, application volumes or the database backup. Remove an
unused Portainer manager image only by its specific image reference if desired;
the LinuxServer socket-proxy image is shared with active services. Do not prune.

## Remaining: access and local configuration

- Remove Portainer's Caddy route, Pi-hole DNS records, Homer/dashboard links,
  bookmarks and external automation. Their live configuration is not stored
  in this checkout; changing the Compose source alone does not remove them.
  Validate/reload only the affected configuration, keeping Arcane's route.
- Remove any manually installed Portainer agents on either host after checking
  their actual identity and consumers. None was declared in this repo. Keep
  Arcane's manager, GMK agent and their socket proxies. GMK's Docker TLS listener
  may have other consumers;
  assess it separately before changing its host configuration.
- Close maintenance tunnels and remove any temporary SSH forwarding exception,
  validating SSH configuration before reload.
- Retire Portainer-only Infisical folders, machine-identity permissions and API
  credentials. The old registry-token folder was already absent during cleanup.
  Keep `/opentofu/arcane`, its registry-token folder and all active application
  folders. Do not revoke Docker Hub or Git tokens now used by Arcane merely
  because Portainer previously used the same tokens.
- Review ignored files left under `opentofu/portainer` locally. These can include
  tfvars, provider caches and local state copies; no contents were exposed or
  deleted by the repo cleanup. Archive anything needed, then remove only those
  retired local files. Shared AWS credentials and state infrastructure stay.

## Cleanup record for recovery

The old registry-token Infisical folder had already been removed. The destroy
plan therefore used `infisical_dockerhub_registry_tokens_enabled=false` and
`dockerhub_registries={}` to avoid reading retired secrets. The same inputs were
supplied when applying that saved plan. This removed Portainer's credential
records; it did not revoke the underlying Docker Hub tokens or delete Infisical
secrets. The saved before/after states and operation logs contain sensitive
data and must remain private.
