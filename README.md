# homelab-gitops

Declarative homelab infrastructure for Docker Compose applications managed with Portainer, OpenTofu, and Infisical.

## Purpose

This repository is the source of truth for my homelab container deployments. Application stacks are defined as Docker Compose files under `hosts/`, and Portainer deploys those stacks from this Git repository.

OpenTofu manages Portainer objects such as Git-backed stacks, registries, templates, and stack environment values. Infisical is the source of truth for secrets that need to be injected into Portainer stack configuration.

The goal is a lightweight GitOps workflow without Kubernetes: changes are reviewed in Git, applied through Portainer, and kept reproducible across hosts.

## Repository Structure

```text
.
├── Justfile                           # Short commands for each OpenTofu root
├── hosts/
│   ├── <host>/
│   │   ├── <app>/compose.yml        # Per-host Docker Compose stacks
│   │   └── daemon.json              # Host Docker daemon config
│   ├── 6194cicero-gmk-g3/
│   └── 6194cicero-raspberrypi/
├── opentofu/
│   ├── aws/
│   │   └── iam-roles-anywhere/      # AWS trust anchor, roles, profiles, and root CA certificate
│   ├── backends/
│   │   └── homelab.s3.tfbackend     # Shared non-secret backend configuration
│   ├── bootstrap/
│   │   └── state-backend/           # Shared OpenTofu state bucket
│   ├── modules/
│   │   └── portainer-stack/         # Shared Portainer stack module
│   └── portainer/                   # OpenTofu root for Portainer-managed objects
├── templates/
│   └── portainer/                   # Portainer custom template sources
├── Dockerfiles/
│   ├── caddy/                       # Custom Caddy image
│   └── drawio/                      # Custom Draw.io image
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

### Prerequisites

Install OpenTofu and `just`. AWS roots also require AWS CLI credentials with
access to the shared state bucket and the resources managed by the selected
root. The IAM Roles Anywhere client workflow additionally uses OpenSSL, `jq`,
and the AWS IAM Roles Anywhere credential helper.

### Operations

Detailed setup and operation notes live in:

```text
opentofu/portainer/README.md
opentofu/aws/iam-roles-anywhere/README.md
opentofu/bootstrap/state-backend/README.md
```

Typical workflow:

```shell
just init portainer
just plan portainer
just apply portainer
```

The repository `Justfile` accepts these root paths:

```text
portainer
aws/iam-roles-anywhere
bootstrap/state-backend
```

All roots reuse the committed, non-secret backend configuration at
`opentofu/backends/homelab.s3.tfbackend`. It contains only the state bucket name
and AWS region; credentials must come from the AWS CLI configuration or
environment. Each root's committed backend block selects its own state key.

Use `opentofu/portainer/terraform.tfvars.example` as the starting point for local ignored configuration.

AWS IAM Roles Anywhere has its own OpenTofu root and state under
`opentofu/aws/iam-roles-anywhere/`. Its README documents local CA key handling,
least-privilege role configuration, and initialization.

The shared state bucket is managed independently under
`opentofu/bootstrap/state-backend/`. All roots use the shared backend
configuration for the bucket and region, while their committed backend blocks
select distinct state object keys.

### Secrets

Infisical stores secrets used by the Portainer OpenTofu root and by Portainer stacks.

Primary Infisical paths:

```text
/opentofu/portainer
/opentofu/portainer/dockerhub-registry-tokens
/hosts/<host>/<app>
```

Local `*.tfvars` files are ignored and should only contain bootstrap values, local auth for OpenTofu runs, and temporary fallback values. Secrets still flow into OpenTofu state and Portainer configuration, so the state backend must be protected.

The IAM Roles Anywhere root is an explicit local-only exception for its CA
private key, as requested. Keep its ignored `local.auto.tfvars` at mode `0600`;
because the key is consumed by the TLS provider, it also enters that root's
encrypted remote state. Keep a protected offline backup of the key and secure
the state bucket.
