# Portainer OpenTofu

This OpenTofu root manages existing Portainer objects while leaving the Portainer stack itself as bootstrap infrastructure.

## Layout

This directory is one OpenTofu root. Files are split by concern for readability:

```text
versions.tofu
providers.tofu

variables.infisical.tofu
variables.portainer.tofu
variables.registries.tofu
variables.stacks.tofu

infisical.portainer.tofu
infisical.registries.tofu
infisical.stack-env.tofu

data.portainer.tofu
registries.tofu
stacks.tofu
stacks.<host>.tofu
custom_templates.tofu
outputs.tofu
```

To add another stack, add an entry to the matching host file. The shared module block in `stacks.tofu` will pick it up through `local.stacks`.

## Configure

Copy the example values into a local ignored file and fill in your repository and Infisical bootstrap settings:

```shell
cp terraform.tfvars.example local.auto.tfvars
```

Recommended `local.auto.tfvars` contents:

```hcl
infisical_auth = {
  universal = {
    client_id     = "..."
    client_secret = "..."
  }
}

repository_url            = "https://github.com/user/project.git"
repository_reference_name = "refs/heads/main"

infisical_project_id                        = "your-infisical-project-id"
infisical_env_slug                          = "prod"
infisical_portainer_config_enabled          = true
infisical_stack_env_enabled                 = true
infisical_dockerhub_registry_tokens_enabled = true
```

Keep these in local tfvars:

- Infisical bootstrap/auth values: `infisical_project_id`, `infisical_env_slug`, `infisical_auth`, and optional `infisical_host`
- Repository settings: `repository_url`, `repository_reference_name`, and any stack-specific reference overrides
- Non-secret Portainer object shape: `dockerhub_registries`, Git credential IDs, and stack behavior toggles
- Temporary local fallback values in `stack_env` or `dockerhub_registry_tokens` only while actively testing

Move these out of local tfvars after they exist in Infisical:

- `portainer_endpoint`, `portainer_api_key`, and Docker Hub registry tokens
- Stack app secrets under `stack_env`

If you are not using Infisical for the Portainer provider yet, local `portainer_endpoint` and `portainer_api_key` still work.

If the actual Portainer environment name differs from the repo host key and you are not storing the map in Infisical, update:

```hcl
portainer_environment_names = {
  "6194cicero-gmk-g3"      = "6194-cicero-gmk-g3"
  "6194cicero-raspberrypi" = "6194-cicero-raspberrypi"
}
```

If the existing stack uses a saved Portainer Git credential, set:

```hcl
git_repository_authentication = true
repository_git_credential_id  = 1
```

## Infisical Provider Config

Portainer provider settings can be read from Infisical before the Portainer provider is configured.
The default folder is:

```text
/opentofu/portainer
```

Supported secret names:

```text
portainer_endpoint
portainer_api_key
```

Enable this with:

```hcl
infisical_portainer_config_enabled = true
```

Infisical values override matching local variables.
Local variables remain useful as fallbacks while migrating.

## Infisical Stack Env

Portainer stack environment variables can be read from Infisical and passed to each `portainer_stack` resource.
The default folder convention is:

```text
/hosts/<host>/<app>
```

For example, the stack key `6194cicero-gmk-g3/pihole` reads from `/hosts/6194cicero-gmk-g3/pihole`.
Secret names in that folder become Portainer environment variable names.

Enable Infisical in `local.auto.tfvars`:

```hcl
infisical_stack_env_enabled = true
infisical_project_id        = "your-infisical-project-id"
infisical_env_slug          = "prod"
```

For self-hosted Infisical, set `infisical_host`.
If your folder prefix is not `/hosts`, set `infisical_stack_env_path_prefix`.
If only some stacks have Infisical folders, set `infisical_stack_env_stack_keys` to that subset.

To test one stack against `dev` while the rest use `prod`, override only that stack:

```hcl
infisical_stack_env_overrides = {
  "6194cicero-gmk-g3/speedtest" = {
    env_slug = "dev"
  }
}
```

Use this for development when you want the stack to exercise the same secret names and structure it will use in production.
Use local `stack_env` for fast, temporary, non-secret experiments.
With the current merge order, Infisical overrides local `stack_env` for the same environment variable name.

`stack_env` remains available for local fallback values.
When Infisical is enabled, Infisical values override matching keys from `stack_env`.
These secrets are still materialized into OpenTofu state and into Portainer stack configuration, so protect the state backend.

## Docker Hub Registries

Docker Hub registry metadata is managed through `dockerhub_registries`.
Tokens can be read from Infisical.
The default token folder is:

```text
/opentofu/portainer/dockerhub-registry-tokens
```

Secret names must match the `dockerhub_registries` map keys, for example:

```text
dockerhub_personal
dockerhub_dhi
```

Enable Infisical tokens with:

```hcl
infisical_dockerhub_registry_tokens_enabled = true
```

`dockerhub_registry_tokens` remains available for local fallback values.
When Infisical is enabled, Infisical values override matching keys from `dockerhub_registry_tokens`.
Registry PATs are still stored in OpenTofu state and Portainer registry configuration, so protect the state backend.

Each registry entry must include Portainer's registry `type`; Docker Hub is `6`.
The registry map key must exist either in Infisical or in `dockerhub_registry_tokens`.

```hcl
dockerhub_registries = {
  dockerhub_personal = {
    name     = "Docker Hub - Primary"
    type     = 6
    url      = "docker.io"
    username = "dockerhub-user"
  }

  dockerhub_dhi = {
    name     = "Docker Hub - DHI"
    type     = 6
    url      = "your-dhi-registry-url"
    username = "dockerhub-user"
  }
}
```

If importing existing registries, use the registry ID from Portainer:

```shell
tofu import 'portainer_registry.dockerhub["dockerhub_personal"]' <REGISTRY_ID>
tofu import 'portainer_registry.dockerhub["dockerhub_dhi"]' <REGISTRY_ID>
```

## Import existing stacks

Initialize the provider:

```shell
tofu init
```

Find the existing stack ID and endpoint ID in Portainer, then import it.
The Portainer provider expects this import ID format:

```text
<endpoint_id>-<stack_id>-<deployment_type>[-<method>]
```

### Example - Draw.io

For Draw.io on `6194cicero-gmk-g3`, using endpoint ID `5`, stack ID `52`, standalone deployment, and Git repository mode:

```shell
tofu import 'module.stack["6194cicero-gmk-g3/drawio"].portainer_stack.this' '5-52-standalone-repository'
```

Check drift before applying:

```shell
tofu plan
```

If the plan wants to change repository settings, Git credentials, webhook settings, polling interval, ownership, `pull_image`, or `prune`, adjust the OpenTofu inputs to match the existing Portainer stack before applying.
