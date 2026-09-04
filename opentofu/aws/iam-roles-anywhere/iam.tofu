locals {
  role_managed_policy_attachments = {
    for attachment in flatten([
      for role_name, role in var.roles : [
        for policy_arn in role.managed_policy_arns : {
          key        = "${role_name}:${policy_arn}"
          role_name  = role_name
          policy_arn = policy_arn
        }
      ]
    ]) : attachment.key => attachment
  }
}

data "aws_iam_policy_document" "roles_anywhere_assume_role" {
  for_each = var.roles

  statement {
    sid    = "AllowRolesAnywhereFromTrustedCA"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
      "sts:SetSourceIdentity",
      "sts:TagSession",
    ]

    principals {
      type        = "Service"
      identifiers = ["rolesanywhere.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_rolesanywhere_trust_anchor.homelab.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/x509Issuer/CN"
      values   = [var.ca_common_name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/x509Subject/CN"
      values   = tolist(each.value.allowed_subject_common_names)
    }
  }
}

resource "aws_iam_role" "roles_anywhere" {
  for_each = var.roles

  name                 = each.key
  description          = coalesce(each.value.description, "Role assumed through IAM Roles Anywhere")
  assume_role_policy   = data.aws_iam_policy_document.roles_anywhere_assume_role[each.key].json
  max_session_duration = each.value.max_session_duration
  permissions_boundary = each.value.permissions_boundary_arn
}

resource "aws_iam_role_policy_attachment" "roles_anywhere" {
  for_each = local.role_managed_policy_attachments

  role       = aws_iam_role.roles_anywhere[each.value.role_name].name
  policy_arn = each.value.policy_arn
}

resource "aws_iam_role_policy" "roles_anywhere" {
  for_each = {
    for role_name, role in var.roles : role_name => role
    if role.inline_policy_json != null
  }

  name   = "${each.key}-permissions"
  role   = aws_iam_role.roles_anywhere[each.key].id
  policy = each.value.inline_policy_json
}
