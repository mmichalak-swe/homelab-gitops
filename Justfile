set shell := ["bash", "-euo", "pipefail", "-c"]

repo := justfile_directory()
tofu_dir := repo + "/opentofu"
backend_config := tofu_dir + "/backends/homelab.s3.tfbackend"

# List available recipes.
default:
    @just --list

# Initialize an OpenTofu root, for example: just init portainer
init root:
    tofu -chdir="{{tofu_dir}}/{{root}}" init -backend-config="{{backend_config}}"

# Reinitialize a root after backend configuration changes.
reconfigure root:
    tofu -chdir="{{tofu_dir}}/{{root}}" init -reconfigure -backend-config="{{backend_config}}"

# Validate an initialized OpenTofu root.
validate root:
    tofu -chdir="{{tofu_dir}}/{{root}}" validate

# Show a speculative plan without writing a local plan artifact.
plan root:
    tofu -chdir="{{tofu_dir}}/{{root}}" plan

# Interactively apply an OpenTofu root.
apply root:
    tofu -chdir="{{tofu_dir}}/{{root}}" apply

# Check formatting across tracked OpenTofu files without touching local tfvars.
fmt:
    git -C "{{repo}}" ls-files -z -co --exclude-standard -- 'opentofu/**/*.tf' 'opentofu/**/*.tofu' 'opentofu/**/*.tfvars' | while IFS= read -r -d '' file; do test ! -f "{{repo}}/$file" || printf '%s\0' "$file"; done | xargs -0 tofu fmt -check
    git -C "{{repo}}" ls-files -z -co --exclude-standard -- 'opentofu/**/*.tfvars.example' | while IFS= read -r -d '' file; do test ! -f "{{repo}}/$file" || tofu fmt -check - < "{{repo}}/$file"; done

# Initialize, validate, and plan one root.
check root: (init root) (validate root) (plan root)

# Convenience aliases for the Portainer root.
init-portainer: (init "portainer")
plan-portainer: (plan "portainer")
apply-portainer: (apply "portainer")

# Convenience aliases for the IAM Roles Anywhere root.
init-roles-anywhere: (init "aws/iam-roles-anywhere")
plan-roles-anywhere: (plan "aws/iam-roles-anywhere")
apply-roles-anywhere: (apply "aws/iam-roles-anywhere")

# Convenience aliases for the state backend root.
init-state-backend: (init "bootstrap/state-backend")
plan-state-backend: (plan "bootstrap/state-backend")
apply-state-backend: (apply "bootstrap/state-backend")
