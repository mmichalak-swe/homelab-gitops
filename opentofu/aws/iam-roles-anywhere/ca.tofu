resource "tls_self_signed_cert" "root_ca" {
  private_key_pem = var.ca_private_key_pem

  subject {
    common_name  = var.ca_common_name
    organization = var.ca_organization
  }

  validity_period_hours = var.ca_validity_period_hours
  is_ca_certificate     = true
  max_path_length       = 0
  set_authority_key_id  = true
  set_subject_key_id    = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
  ]
}

resource "aws_rolesanywhere_trust_anchor" "homelab" {
  name    = "${var.name_prefix}-trust-anchor"
  enabled = true

  source {
    source_data {
      x509_certificate_data = tls_self_signed_cert.root_ca.cert_pem
    }

    source_type = "CERTIFICATE_BUNDLE"
  }

  lifecycle {
    prevent_destroy = true
  }
}
