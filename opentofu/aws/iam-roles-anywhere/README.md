# AWS IAM Roles Anywhere

This OpenTofu root creates:

- A self-signed root CA certificate from a private key supplied in ignored local tfvars.
- An AWS IAM Roles Anywhere trust anchor backed by the public CA certificate.
- The `s3-service-user` and `terraform-service-user` IAM roles, with trust policies restricted to the trust anchor, CA issuer CN, and per-role allowlists of end-entity certificate subject CNs.
- A dedicated IAM Roles Anywhere profile for each role.

The CA private key is intentionally an input rather than a `tls_private_key` resource. The TLS provider stores private keys used by certificate resources in state, but this avoids making OpenTofu the generator and only copy of the long-lived signing key. The key still enters state when `tls_self_signed_cert` is applied, so protect both the ignored tfvars file and the remote state bucket. For stronger isolation, generate the complete CA outside OpenTofu and change this root to read only its public certificate.

## Configure

Run commands in this README from the repository root. Copy the example into an
ignored local file:

```shell
cp \
  opentofu/aws/iam-roles-anywhere/terraform.tfvars.example \
  opentofu/aws/iam-roles-anywhere/local.auto.tfvars
chmod 600 opentofu/aws/iam-roles-anywhere/local.auto.tfvars
```

Choose a protected directory for the CA and client material, then generate a
dedicated CA private key:

```shell
umask 077
RA_DIR="$HOME/.config/aws/rolesanywhere"
mkdir -p "$RA_DIR"
chmod 700 "$RA_DIR"
openssl genpkey \
  -algorithm RSA \
  -pkeyopt rsa_keygen_bits:4096 \
  -out "$RA_DIR/ca.key.pem"
chmod 600 "$RA_DIR/ca.key.pem"
```

Paste the complete PEM from `ca.key.pem` into `ca_private_key_pem` in
`local.auto.tfvars`. Do not reuse a web-server or SSH private key. Retain a
usable, securely stored copy of this exact CA key because it is required to
issue and renew client certificates. Also keep a protected offline backup:
losing every copy prevents further issuance, while compromise lets an attacker
mint certificates trusted by the anchor. The CA key is not used by
`aws_signing_helper` during normal role assumption and should otherwise remain
offline or tightly access-controlled.

Set these values in `local.auto.tfvars`:

- `aws_region`: the region for the trust anchor and profile.
- Per-role `allowed_subject_common_names`: exact client certificate CNs permitted by that role's trust policy.
- Per-role `managed_policy_arns` and/or `inline_policy_json`: the AWS permissions that role grants. Both roles grant nothing by default.
- Optional per-role profile session policies to further restrict, never expand, role permissions.

The two managed roles are named exactly `s3-service-user` and `terraform-service-user`. Each has a separate profile and defaults to a one-hour maximum session. Optional permissions boundaries are supported with `permissions_boundary_arn`.

Avoid attaching broad AWS managed policies such as `AmazonS3FullAccess` or `AdministratorAccess`. Scope `s3-service-user` to explicit bucket and object ARNs. Do not let `terraform-service-user` modify its own role, permissions boundary, trust anchor, or profile; use a separate bootstrap identity for identity-plane changes so a compromised workload certificate cannot grant itself more access.

Use a separate bootstrap AWS profile or environment variables when OpenTofu
must read remote state or manage IAM Roles Anywhere itself. Do not reuse either
new Roles Anywhere profile as the bootstrap profile: doing so creates a cycle
when its ARN must first be read from state. Do not put long-lived AWS access
keys in tfvars; the S3 backend cannot read ordinary input variables anyway.

## Initialize and review

This root uses the repository's existing protected S3 state bucket with a separate state key:

```text
aws/iam-roles-anywhere/terraform.tfstate
```

From the repository root, select the existing bootstrap identity, then
initialize and review without changing AWS:

```shell
export AWS_PROFILE=bootstrap-admin
aws sts get-caller-identity
just init aws/iam-roles-anywhere
just fmt
just validate aws/iam-roles-anywhere
just plan aws/iam-roles-anywhere
```

Replace `bootstrap-admin` with the profile that currently has permission to use
the state backend and manage these resources.

Only run `tofu apply` after reviewing the role permissions, allowed certificate subjects, target AWS account, region, and planned resources.

After apply, write the public CA certificate beside its protected key:

```shell
RA_DIR="$HOME/.config/aws/rolesanywhere"
AWS_PROFILE=bootstrap-admin tofu \
  -chdir=opentofu/aws/iam-roles-anywhere \
  output -raw ca_certificate_pem > "$RA_DIR/ca.cert.pem.new"
openssl x509 -in "$RA_DIR/ca.cert.pem.new" -noout -subject -issuer -dates
mv "$RA_DIR/ca.cert.pem.new" "$RA_DIR/ca.cert.pem"
chmod 644 "$RA_DIR/ca.cert.pem"
```

The CA private key is never uploaded to AWS. Only the public certificate is registered as the trust anchor.

## Client certificates

Issue a distinct end-entity certificate for each workload. Its Subject CN must
exactly match one entry in its target role's
`allowed_subject_common_names`. The role name and certificate CN happen to be
the same for the two defaults, but the trust policy matches the CN rather than
deriving it from the role name. Do not use the CA certificate itself as a
client certificate.

The following example creates one-year certificates for both current roles.
Use a shorter `-days` value if practical. Client-certificate validity is not
managed by OpenTofu, so the value in this command is authoritative:

```shell
umask 077
RA_DIR="$HOME/.config/aws/rolesanywhere"

cat > "$RA_DIR/client-cert.ext" <<'EOF'
basicConstraints=critical,CA:FALSE
keyUsage=critical,digitalSignature
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
EOF

issue_client_certificate() {
  local role_name="$1"
  local certificate_serial
  local key_file="$RA_DIR/$role_name.key.pem"
  local cert_file="$RA_DIR/$role_name.cert.pem"
  local new_key_file="$key_file.new"
  local new_cert_file="$cert_file.new"
  local csr_file="$RA_DIR/$role_name.csr.pem"

  openssl genpkey \
    -algorithm RSA \
    -pkeyopt rsa_keygen_bits:3072 \
    -out "$new_key_file"

  openssl req \
    -new \
    -key "$new_key_file" \
    -subj "/CN=$role_name" \
    -out "$csr_file"

  certificate_serial="0x$(openssl rand -hex 16)"
  openssl x509 \
    -req \
    -in "$csr_file" \
    -CA "$RA_DIR/ca.cert.pem" \
    -CAkey "$RA_DIR/ca.key.pem" \
    -set_serial "$certificate_serial" \
    -days 365 \
    -sha256 \
    -extfile "$RA_DIR/client-cert.ext" \
    -out "$new_cert_file"

  openssl verify -CAfile "$RA_DIR/ca.cert.pem" "$new_cert_file"
  chmod 600 "$new_key_file"
  chmod 644 "$new_cert_file"
  mv "$new_key_file" "$key_file"
  mv "$new_cert_file" "$cert_file"
  rm "$csr_file"
}

issue_client_certificate s3-service-user
issue_client_certificate terraform-service-user

openssl verify \
  -CAfile "$RA_DIR/ca.cert.pem" \
  "$RA_DIR/s3-service-user.cert.pem" \
  "$RA_DIR/terraform-service-user.cert.pem"
```

The persistent files are the CA certificate, protected CA key, client
certificates, client keys, and the non-secret extension file. The CSRs are
removed after issuance, and random serial numbers avoid a generated `.srl`
file.

Inspect exact certificate dates at any time:

```shell
openssl x509 \
  -in "$HOME/.config/aws/rolesanywhere/s3-service-user.cert.pem" \
  -noout -subject -issuer -dates
```

## Configure AWS profiles

Install `aws_signing_helper` using the
[official AWS instructions](https://docs.aws.amazon.com/rolesanywhere/latest/userguide/credential-helper.html)
and confirm that it is executable:

```shell
command -v aws_signing_helper
```

Use the bootstrap profile—not either profile being created—to read the
resulting ARNs:

```shell
export AWS_PROFILE=bootstrap-admin
TOFU_ROOT="opentofu/aws/iam-roles-anywhere"

tofu -chdir="$TOFU_ROOT" output -raw trust_anchor_arn
tofu -chdir="$TOFU_ROOT" output -json role_arns | jq
tofu -chdir="$TOFU_ROOT" output -json profile_arns | jq
```

Add two profiles to `~/.aws/config`. Replace every placeholder with the
absolute helper/certificate/key path and the matching output ARN. AWS config
does not expand shell variables in `credential_process`:

```ini
[profile s3-service-user]
region = us-east-1
credential_process = /absolute/path/aws_signing_helper credential-process --certificate /absolute/path/s3-service-user.cert.pem --private-key /absolute/path/s3-service-user.key.pem --trust-anchor-arn arn:aws:rolesanywhere:REGION:ACCOUNT:trust-anchor/ID --profile-arn arn:aws:rolesanywhere:REGION:ACCOUNT:profile/ID --role-arn arn:aws:iam::ACCOUNT:role/s3-service-user

[profile terraform-service-user]
region = us-east-1
credential_process = /absolute/path/aws_signing_helper credential-process --certificate /absolute/path/terraform-service-user.cert.pem --private-key /absolute/path/terraform-service-user.key.pem --trust-anchor-arn arn:aws:rolesanywhere:REGION:ACCOUNT:trust-anchor/ID --profile-arn arn:aws:rolesanywhere:REGION:ACCOUNT:profile/ID --role-arn arn:aws:iam::ACCOUNT:role/terraform-service-user
```

Test each profile:

```shell
AWS_PROFILE=s3-service-user aws sts get-caller-identity
AWS_PROFILE=terraform-service-user aws sts get-caller-identity
```

The AWS CLI and compatible SDKs invoke `credential_process` again when the
one-hour temporary session expires. No manual hourly refresh is necessary.
This automatic refresh works only while the client certificate and its private
key remain valid and readable.

AWS IAM Roles Anywhere uses the profile's default certificate attribute
mappings, which include issuer and subject CN values used by this root's trust
policy.

## Client certificate renewal

Before a client certificate expires, rerun `issue_client_certificate` for its
role name. This generates a new private key and certificate at the paths already
referenced by `credential_process`; the next AWS CLI or SDK invocation uses the
new certificate automatically. Verify it with `openssl verify` and
`aws sts get-caller-identity`.

No OpenTofu apply or AWS-side change is needed when the issuing CA, Subject CN,
role, profile, and trust anchor are unchanged. An apply is required only when
changing managed AWS resources or the authorized CN allowlists. A CA change
requires the separate rollover procedure below.

## CA validity

The root certificate is valid for `87600` hours by default: 3,650 days, or approximately ten years, beginning when OpenTofu first creates it. The private key itself has no expiration. After apply, use `tofu output ca_certificate_validity_end_time` for the exact RFC3339 expiration timestamp.

## CA rotation

The trust anchor has `prevent_destroy = true` to guard against accidental removal. Root CA rollover should follow an explicit procedure: create and distribute a new CA and client certificates, establish the new trust anchor, cut workloads over, then retire the old anchor. Do not casually replace `ca_private_key_pem` in place.
