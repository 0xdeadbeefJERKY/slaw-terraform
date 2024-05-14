# LAB: Enable AWS Organizations
locals {
  username = split("@", var.account_email)[0]
  domain   = split("@", var.account_email)[1]

  account_to_ou = flatten([
    for account, ou_list in var.account_to_ou_mapping : [
      for ou in ou_list : {
        account = account
        ou      = ou
      }
    ]
  ])

  account_to_nested_ou = flatten([
    for account, ou_list in var.account_to_nested_ou_mapping : [
      for ou in ou_list : {
        account = account
        ou      = ou
      }
    ]
  ])

  # LAB: Creating Security Team Permissions in IAM Identity Center
  accounts        = toset([for mapping in local.account_to_ou : mapping.account])
  accounts_nested = toset([for mapping in local.account_to_nested_ou : mapping.account])
}

resource "aws_organizations_organization" "default" {
  feature_set = "ALL"
  # LAB: Enable SCPs, the Security Blanket of AWS
  enabled_policy_types = ["SERVICE_CONTROL_POLICY"]
  # LAB: Enabling the Org Trail
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    # LAB: Bring in the Fed(eration)
    "sso.amazonaws.com",
    # LAB: Buttoning Up the Org
    "account.amazonaws.com"
  ]
}

resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = aws_organizations_organization.default.roots[0].id
}

resource "aws_organizations_organizational_unit" "default" {
  for_each = var.organizational_units

  name      = each.key
  parent_id = aws_organizations_organization.default.roots[0].id
}

# LAB: Buttoning Up the Org
resource "aws_organizations_organizational_unit" "nested" {
  for_each = flatten([
    for ou, nested_ous in var.organizational_units : {
      for nested_ou in nested_ous : nested_ou => ou
    } if length(nested_ous) > 0
  ])[0]

  name      = each.key
  parent_id = aws_organizations_organizational_unit.default[each.value].id
}

resource "aws_organizations_account" "nested" {
  for_each = tomap({
    for mapping in local.account_to_nested_ou : mapping.account => mapping
  })

  name      = each.value.account
  email     = "${local.username}+${lower(each.value.account)}@${local.domain}"
  parent_id = aws_organizations_organizational_unit.nested[each.value.ou].id
}

resource "aws_organizations_account" "security_audit" {
  name = "SecurityAudit"
  # LAB: OUs, SCPs and Root User Account Recovery
  # Use unique email address for the "new" SecurityAudit account
  email     = "${local.username}+securityaudit1@${local.domain}"
  parent_id = aws_organizations_organizational_unit.security.id
}

# LAB: OUs, SCPs and Root User Account Recovery
# Run `terraform state mv aws_organizations_account.security_audit 'aws_organizations_account.default["LogArchive"]'` 

resource "aws_organizations_account" "default" {
  for_each = tomap({
    for mapping in local.account_to_ou : mapping.account => mapping
  })

  name      = each.value.account
  email     = "${local.username}+${lower(each.value.account)}@${local.domain}"
  parent_id = each.value.ou == "Security" ? aws_organizations_organizational_unit.security.id : aws_organizations_organizational_unit.default[each.value.ou].id
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
  # LAB: OUs, SCPs and Root User Account Recovery
  # Detach the "protect root" SCP from the root of the OU hierarchy and attach
  # it all OUs except the "Exceptions" OU
  for_each = toset([for ou in keys(var.organizational_units) : ou if ou != "Exceptions"])

  policy_id = aws_organizations_policy.protect_root.id
  target_id = aws_organizations_organizational_unit.default[each.value].id
}

# LAB: Buttoning Up the Org
resource "aws_account_alternate_contact" "operations" {
  for_each = toset(["OPERATIONS", "BILLING", "SECURITY"])

  alternate_contact_type = each.value
  name                   = var.alternate_contact_name
  title                  = var.alternate_contact_title
  email_address          = var.alternate_contact_email_address
  phone_number           = var.alternate_contact_phone_number
}

# LAB: Enable Delegated Administrator for Identity Center and CloudTrail
resource "aws_organizations_delegated_administrator" "iam" {
  account_id        = aws_organizations_account.default["IAM"].id
  service_principal = "sso.amazonaws.com"
}

# https://github.com/hashicorp/terraform-provider-aws/issues/29179#issuecomment-1836989656
# Currently, Terraform doesn't support creating a CloudTrail delegated 
# administrator using the CloudTrail API, so it has to be done manually:
#
# $ SECURITY_AUDIT_ID=$(aws organizations list-accounts --query 'Accounts[?Name==`SecurityAudit`].Id' --output text)
# $ aws cloudtrail register-organization-delegated-admin --member-account-id $SECURITY_AUDIT_ID
