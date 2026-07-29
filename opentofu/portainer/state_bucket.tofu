resource "aws_s3_bucket" "portainer_state" {
  bucket        = var.state_bucket_name
  force_destroy = false

  tags = merge(var.state_bucket_tags, {
    ManagedBy = "OpenTofu"
    Purpose   = "Portainer OpenTofu state"
  })

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_ownership_controls" "portainer_state" {
  bucket = aws_s3_bucket.portainer_state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "portainer_state" {
  bucket = aws_s3_bucket.portainer_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "portainer_state" {
  bucket = aws_s3_bucket.portainer_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "portainer_state" {
  bucket = aws_s3_bucket.portainer_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "portainer_state" {
  bucket = aws_s3_bucket.portainer_state.id

  depends_on = [aws_s3_bucket_versioning.portainer_state]

  rule {
    id     = "retain-five-state-versions"
    status = "Enabled"

    filter {
      prefix = "portainer/terraform.tfstate"
    }

    noncurrent_version_expiration {
      # The current version plus four noncurrent versions retains five snapshots.
      newer_noncurrent_versions = 4
      noncurrent_days           = 1
    }
  }
}
