# Raspberry Pi host bootstrap

Arcane and its socket proxy are manually bootstrapped. All application stacks,
including Caddy and Pi-hole/Unbound, are managed by `opentofu/arcane`.

## Arcane owns the shared network definition

`arcane/compose.yml` now defines the Pi's `caddy-net` with the same bridge driver,
subnet and allocation range (`172.18.0.0/24`) and gateway (`172.18.0.1`) formerly
declared by Portainer. Caddy, Pi-hole and the other applications consume it as
external. Portainer's bootstrap Compose file has been removed from the repo;
the remaining host teardown removes only its exact containers and private
network, leaving `caddy-net` intact.

This change moves the definition in the repository; it does not relabel or
recreate a live Docker network. Keep all existing static addresses, endpoints
and the network ID during the handover.

## Adopt the existing network

Before the first Arcane bootstrap `up` with this definition, run on the Pi:

```shell
arcane_bootstrap_project=$(docker --host unix:///var/run/docker.sock inspect arcane --format '{{index .Config.Labels "com.docker.compose.project"}}')
arcane_caddy_network_id=$(docker --host unix:///var/run/docker.sock network inspect caddy-net --format '{{.Id}}')
docker --host unix:///var/run/docker.sock network inspect caddy-net --format 'id={{.Id}} driver={{.Driver}} labels={{json .Labels}} ipam={{json .IPAM.Config}} containers={{json .Containers}}'
docker --host unix:///var/run/docker.sock compose version
```

Use the same shell throughout. Verify the bootstrap project name is nonempty
and identifies the existing Arcane bootstrap (normally `arcane`). Do not change
the project name or bootstrap environment values during this handover.

Verify the existing network matches the declared driver/IPAM and its
`com.docker.compose.network` label is `caddy-net`. Its project label may still
name Portainer. Compose can reuse a network with a different project label
when its network label and configuration hash match (or no hash is recorded),
but warns about the old project. A differing configuration hash can trigger
network recreation; do not treat every warning or mismatch as harmless.
[Compose's reuse/recreation behavior](https://github.com/docker/compose/blob/v2.40.3/pkg/compose/create.go)
explains these checks. Verify behavior with the Compose version installed on
the Pi rather than assuming the repository edit changes live ownership labels.

From the repository root, using your existing protected bootstrap environment
(substitute its actual path if it differs from this example):

```shell
docker --host unix:///var/run/docker.sock compose --dry-run --env-file /etc/arcane/bootstrap.env -p "$arcane_bootstrap_project" -f hosts/6194cicero-raspberrypi/arcane/compose.yml up -d
```

Review the dry run. **Do not proceed if it proposes removing/recreating
`caddy-net`, rejects its labels, or otherwise cannot reuse the network.**
Investigate the mismatch first; do not force-disconnect other services or prune
networks. Once it confirms reuse, run:

```shell
docker --host unix:///var/run/docker.sock compose --env-file /etc/arcane/bootstrap.env -p "$arcane_bootstrap_project" -f hosts/6194cicero-raspberrypi/arcane/compose.yml up -d
test "$arcane_caddy_network_id" = "$(docker --host unix:///var/run/docker.sock network inspect caddy-net --format '{{.Id}}')"
```

Verify Arcane, DNS and HTTPS routes remain healthy. Then follow the
[Portainer host cleanup](../../docs/portainer-retirement.md).

The historical project label can remain `portainer` on the reused network;
Arcane's Compose file is now the source of its desired configuration. Renaming
that label is not needed to retire Portainer. If metadata ownership must also
change, plan a separate disruptive recreation of the shared network and its
attached endpoints; do not do it as incidental cleanup.

## Fresh hosts and normal operation

On a fresh Pi, follow the [Arcane bootstrap guide](../../opentofu/arcane/README.md).
Starting its bootstrap project creates `caddy-net` with Arcane's Compose labels
before application projects are deployed. Do not create this network manually
without those labels or add a network-only application project.

Use `compose up -d` for manager upgrades and `compose stop` for a temporary
manager shutdown. Arcane's bootstrap now declares the shared network as managed,
so `compose down` may attempt to remove it; do not use it casually while
applications depend on the network. Do not use a historical Portainer Compose
file for teardown: it may still declare this network as managed.

This applies only to the Pi. GMK Caddy continues to own its own `caddy-net`;
its network definition and ownership are unchanged.
