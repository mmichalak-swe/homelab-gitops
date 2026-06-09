# Portainer Terraform

This Terraform root manages existing Portainer objects while leaving the Portainer stack itself as bootstrap infrastructure.

## Layout

Stack behavior is shared in `stacks.tf`. Host-specific stack inventory lives in one file per host:

```text
stacks.tf
stacks.6194cicero-gmk-g3.tf
stacks.6194cicero-raspberrypi.tf
```

To add another stack, add an entry to the matching host file. The shared module block in `stacks.tf` will pick it up through `local.stacks`.

## Configure

Copy the example values into a local ignored file and fill in your real Portainer/repository settings:

```shell
cp terraform.tfvars.example local.auto.tfvars
```

Prefer environment variables for Portainer credentials:

```shell
export PORTAINER_API_KEY="ptr_..."
```

If the actual Portainer environment name differs from the repo host key, update:

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

## Docker Hub Registries

Docker Hub registries are managed through `dockerhub_registries` and `dockerhub_registry_tokens`.
Keep PATs in `local.auto.tfvars` or another secure variable source because they will also be stored in Terraform state.
Each registry entry must include Portainer's registry `type`; Docker Hub is `6`.
The registry map key must also exist in `dockerhub_registry_tokens`.

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

dockerhub_registry_tokens = {
  dockerhub_personal = "dckr_pat_..."
  dockerhub_dhi      = "dckr_pat_..."
}
```

If importing existing registries, use the registry ID from Portainer:

```shell
terraform import 'portainer_registry.dockerhub["dockerhub_personal"]' <REGISTRY_ID>
terraform import 'portainer_registry.dockerhub["dockerhub_dhi"]' <REGISTRY_ID>
```

## Import existing stacks

Initialize the provider:

```shell
terraform init
```

Find the existing stack ID and endpoint ID in Portainer, then import it.
The Portainer provider expects this import ID format:

```text
<endpoint_id>-<stack_id>-<deployment_type>[-<method>]
```

### Example - Draw.io

For Draw.io on `6194cicero-gmk-g3`, using endpoint ID `5`, stack ID `52`, standalone deployment, and Git repository mode:

```shell
terraform import 'module.stack["6194cicero-gmk-g3/drawio"].portainer_stack.this' '5-52-standalone-repository'
```

Check drift before applying:

```shell
terraform plan
```

The first goal is a plan with no unexpected stack redeploy. If the plan wants to change repository settings, Git credentials, webhook settings, polling interval, ownership, `pull_image`, or `prune`, adjust the Terraform inputs to match the existing Portainer stack before applying.
