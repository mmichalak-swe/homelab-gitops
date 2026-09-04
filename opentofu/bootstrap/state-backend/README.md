# Shared OpenTofu State Bucket

This OpenTofu root owns the existing S3 bucket and its bucket-wide security settings. Its lifecycle rule applies to every object because the bucket is dedicated to OpenTofu state. Portainer, IAM Roles Anywhere, and this root store separate states in the same bucket:

```text
portainer/terraform.tfstate
aws/iam-roles-anywhere/terraform.tfstate
aws/bootstrap/terraform.tfstate
```

All roots use the shared non-secret partial backend configuration at
`opentofu/backends/homelab.s3.tfbackend`. Backend configuration cannot reference
ordinary input variables or outputs because the backend is initialized before
the rest of the configuration. AWS credentials remain outside this file.

This root is the sole owner of the bucket and its bucket-wide settings.

## Bootstrap constraint

This root stores its own state in the bucket it manages, so the bucket must
already exist before normal remote-backend initialization can succeed. In a
new AWS account or disaster-recovery scenario, create a private, versioned,
encrypted bucket first, use temporary local state to adopt it into this root,
and then initialize the S3 backend. Keep that break-glass operation explicit
and preserve a protected state backup while performing it; it is not part of
normal operation.

The committed backend file contains only the bucket name and region. Keep AWS
credentials in AWS CLI configuration or environment variables, never in the
backend file or tfvars.

## Normal operation

From the repository root, the `Justfile` initializes each root with the same
shared backend file. The committed backend blocks provide distinct keys:

```shell
just init portainer
just init aws/iam-roles-anywhere
just init bootstrap/state-backend
```

The backend identity needs `s3:ListBucket` and object read/write/delete permissions for each state key and corresponding `.tflock` key. The identity managing this root also needs the S3 bucket configuration and tagging permissions represented by its resources.
