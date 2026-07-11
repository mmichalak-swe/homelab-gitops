# homelab-gitops

Declarative homelab infrastructure for Docker Compose applications managed with Portainer, OpenTofu, and Infisical.

## Purpose

This repository is the source of truth for my homelab container deployments. Application stacks are defined as Docker Compose files under `hosts/`, and Portainer deploys those stacks from this Git repository.

OpenTofu manages Portainer objects such as Git-backed stacks, registries, templates, and stack environment values. Infisical is the source of truth for secrets that need to be injected into Portainer stack configuration.

The goal is a lightweight GitOps workflow without Kubernetes: changes are reviewed in Git, applied through Portainer, and kept reproducible across hosts.

## Repository Structure

```text
.
├── hosts/
│   ├── <host>/
│   │   ├── <app>/compose.yml        # Per-host Docker Compose stacks
│   │   └── daemon.json              # Host Docker daemon config
│   ├── 6194cicero-gmk-g3/
│   └── 6194cicero-raspberrypi/
├── opentofu/
│   ├── portainer/                   # OpenTofu root for Portainer-managed objects
│   └── modules/
│       └── portainer-stack/         # Shared Portainer stack module
├── templates/
│   └── portainer/                   # Portainer custom template sources
├── Dockerfiles/
│   └── caddy/                       # Custom image definitions
├── ansible/
│   └── rpi-initial-config.yml       # Initial Raspberry Pi host setup
└── .github/
    ├── renovate.json
    └── workflows/                   # Dependency and security automation
```

## Stack Deployment Model

Each application stack lives under:

```text
hosts/<host>/<app>/compose.yml
```

The Portainer OpenTofu root maps those compose files to Git-backed Portainer stacks. Portainer then pulls from this repository and applies changes according to each stack's settings.

Host-specific stack inventory lives in:

```text
opentofu/portainer/stacks.<host>.tofu
```

Shared stack behavior lives in:

```text
opentofu/portainer/stacks.tofu
opentofu/modules/portainer-stack/
```

## OpenTofu

### Operations

Detailed Portainer/OpenTofu setup and migration notes live in:

```text
opentofu/portainer/README.md
```

Typical workflow:

```shell
cd opentofu/portainer
tofu init
tofu plan
tofu apply
```

Use `opentofu/portainer/terraform.tfvars.example` as the starting point for local ignored configuration.

### Secrets

Infisical stores secrets used by the Portainer OpenTofu root and by Portainer stacks.

Primary Infisical paths:

```text
/opentofu/portainer
/opentofu/portainer/dockerhub-registry-tokens
/hosts/<host>/<app>
```

Local `*.tfvars` files are ignored and should only contain bootstrap values, local auth for OpenTofu runs, and temporary fallback values. Secrets still flow into OpenTofu state and Portainer configuration, so the state backend must be protected.
