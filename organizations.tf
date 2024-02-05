# LAB: Enable AWS Organizations
locals {
  username = split("@", var.account_email)[0]
  domain   = split("@", var.account_email)[1]
}

resource "aws_organizations_organization" "default" {
  feature_set = "ALL"
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
