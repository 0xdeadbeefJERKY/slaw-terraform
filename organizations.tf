# LAB: Enable AWS Organizations
locals {
  username = split("@", var.account_email)[0]
  domain   = split("@", var.account_email)[1]
}

resource "aws_organizations_organization" "default" {
  feature_set = "ALL"
  # LAB: Enable SCPs, the Security Blanket of AWS
  enabled_policy_types = ["SERVICE_CONTROL_POLICY"]
}

resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = aws_organizations_organization.default.roots[0].id
}

resource "aws_organizations_account" "security_audit" {
  name      = "SecurityAudit"
  email     = "${local.username}+securityaudit@${local.domain}"
  parent_id = aws_organizations_organizational_unit.security.id
}

# LAB: Enable SCPs, the Security Blanket of AWS
data "aws_iam_policy_document" "root_scp" {
  version = "2012-10-17"

  statement {
    actions   = ["organizations:LeaveOrganization"]
    resources = ["*"]
    effect    = "Deny"
  }

  statement {
    actions   = ["*"]
    resources = ["*"]
    effect    = "Deny"

    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:root"]
    }
  }
}

resource "aws_organizations_policy" "protect_root" {
  name        = "ProtectRootAndOrg"
  description = "Restrict the root account and the ability to leave AWS Organizations"
  type        = "SERVICE_CONTROL_POLICY"

  content = data.aws_iam_policy_document.root_scp.json
}

resource "aws_organizations_policy_attachment" "protect_root" {
  policy_id = aws_organizations_policy.protect_root.id
  target_id = aws_organizations_organization.default.roots[0].id
}
