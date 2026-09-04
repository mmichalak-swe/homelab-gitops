output "ca_certificate_pem" {
  description = "Public root CA certificate registered with IAM Roles Anywhere."
  value       = tls_self_signed_cert.root_ca.cert_pem
}

output "ca_certificate_validity_end_time" {
  description = "RFC3339 expiration time of the root CA certificate."
  value       = tls_self_signed_cert.root_ca.validity_end_time
}

output "trust_anchor_arn" {
  description = "ARN of the IAM Roles Anywhere trust anchor."
  value       = aws_rolesanywhere_trust_anchor.homelab.arn
}

output "profile_arns" {
  description = "IAM role name to IAM Roles Anywhere profile ARN."
  value = {
    for role_name, profile in aws_rolesanywhere_profile.role : role_name => profile.arn
  }
}

output "role_arns" {
  description = "IAM role name to role ARN."
  value = {
    for role_name, role in aws_iam_role.roles_anywhere : role_name => role.arn
  }
}
