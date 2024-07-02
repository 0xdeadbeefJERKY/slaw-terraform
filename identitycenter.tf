# LAB: Bring in the Fed(eration)
#
# NOTE: Currently, Terraform's AWS provider doesn't allow for modifying the 
# configuration of an Identity Center instance, so the steps involving changes
# to MFA settings must be done manually via the AWS Console (as outlined in the
# lab walkthrough).
#
# NOTE: Additionally, after the Identity Center user is created, you'll have to
# manually log into the AWS Console and send the verification email, visit the
# portal URL, and go through the "forgot password" workflow to create the user's
# password and assign an MFA device.
locals {
  given_name  = split(" ", var.sso_display_name)[0]
  family_name = split(" ", var.sso_display_name)[1]
}

data "aws_ssoadmin_instances" "default" {}

resource "aws_identitystore_group" "admins" {
  display_name      = "Administrators"
  description       = "Full admin"
  identity_store_id = tolist(data.aws_ssoadmin_instances.default.identity_store_ids)[0]
}

# LAB: Creating Security Team Permissions in IAM Identity Center
resource "aws_identitystore_group" "security_admins" {
  provider = aws.iam

  display_name      = "Security Administrators"
  identity_store_id = tolist(data.aws_ssoadmin_instances.default.identity_store_ids)[0]
}

resource "aws_identitystore_group" "iam_admins" {
  provider = aws.iam

  display_name      = "IAM Administrators"
  description       = "Can administer Identity Center"
  identity_store_id = tolist(data.aws_ssoadmin_instances.default.identity_store_ids)[0]
}

resource "aws_identitystore_user" "default" {
  user_name         = var.admin_users[0]
  display_name      = var.sso_display_name
  identity_store_id = tolist(data.aws_ssoadmin_instances.default.identity_store_ids)[0]

  name {
    given_name  = local.given_name
    family_name = local.family_name
  }

  emails {
    primary = true
    value   = "${local.username}+slawsso@${local.domain}"
  }
}

# LAB: Creating Security Team Permissions in IAM Identity Center
resource "aws_identitystore_group_membership" "admins" {
  group_id          = aws_identitystore_group.admins.group_id
  member_id         = aws_identitystore_user.default.user_id
  identity_store_id = tolist(data.aws_ssoadmin_instances.default.identity_store_ids)[0]
}

resource "aws_identitystore_group_membership" "security_admins" {
  group_id          = aws_identitystore_group.security_admins.group_id
  member_id         = aws_identitystore_user.default.user_id
  identity_store_id = tolist(data.aws_ssoadmin_instances.default.identity_store_ids)[0]
}

resource "aws_identitystore_group_membership" "iam_admins" {
  group_id          = aws_identitystore_group.iam_admins.group_id
  member_id         = aws_identitystore_user.default.user_id
  identity_store_id = tolist(data.aws_ssoadmin_instances.default.identity_store_ids)[0]
}

# LAB: Another Me? SSO with IAM Identity Center Part 2
resource "aws_ssoadmin_permission_set" "admin" {
  name         = "AdministratorAccess"
  description  = "Full admin"
  instance_arn = tolist(data.aws_ssoadmin_instances.default.arns)[0]
}

resource "aws_ssoadmin_managed_policy_attachment" "admin" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
}

# LAB: Creating Security Team Permissions in IAM Identity Center
resource "aws_ssoadmin_permission_set" "readonly" {
  provider = aws.iam

  name         = "ReadOnlyAccess"
  instance_arn = tolist(data.aws_ssoadmin_instances.default.arns)[0]
}

resource "aws_ssoadmin_managed_policy_attachment" "readonly" {
  provider = aws.iam

  instance_arn       = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
}

resource "aws_ssoadmin_permission_set" "identity_center_admin" {
  provider = aws.iam

  name         = "IdentityCenterAdministration"
  description  = "Administer AWS IAM Identity Center from a delegated admin account"
  instance_arn = tolist(data.aws_ssoadmin_instances.default.arns)[0]
}

resource "aws_ssoadmin_managed_policy_attachment" "identity_center_admin" {
  provider = aws.iam

  instance_arn       = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AWSSSOMemberAccountAdministrator"
  permission_set_arn = aws_ssoadmin_permission_set.identity_center_admin.arn
}

# Skills Challenge: IAM Identity Center
data "aws_iam_policy_document" "iam_admin" {
  statement {
    sid       = "IamAdmin"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "iam:CreatePolicy*",
      "iam:DeletePolicy*",
      "iam:GetPolicy*",
      "iam:ListPolicies",
      "iam:ListPolicyVersions",
      "iam:SetDefaultPolicyVersion",
      "iam:ListEntitiesForPolicy"
    ]
  }
}

resource "aws_ssoadmin_permission_set_inline_policy" "identity_center_admin" {
  provider = aws.iam

  inline_policy      = data.aws_iam_policy_document.iam_admin.json
  instance_arn       = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.identity_center_admin.arn
}

resource "aws_ssoadmin_permission_set" "security_full_admin" {
  provider = aws.iam

  name         = "SecurityFullAdmin"
  instance_arn = tolist(data.aws_ssoadmin_instances.default.arns)[0]
}

resource "aws_ssoadmin_managed_policy_attachment" "security_full_admin" {
  provider = aws.iam

  instance_arn       = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.security_full_admin.arn
}

resource "aws_ssoadmin_account_assignment" "admin_security_audit" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  principal_id       = aws_identitystore_group.admins.group_id
  principal_type     = "GROUP"
  target_id          = aws_organizations_account.security_audit.id
  target_type        = "AWS_ACCOUNT"
}

# LAB: OUs, SCPs and Root User Account Recovery
# Run `terraform state mv aws_ssoadmin_account_assignment.admin_security_audit aws_ssoadmin_account_assignment.admin_log_archive` 

# LAB: Creating Security Team Permissions in IAM Identity Center
resource "aws_ssoadmin_account_assignment" "admin" {
  for_each = local.accounts

  instance_arn       = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  principal_id       = aws_identitystore_group.admins.group_id
  principal_type     = "GROUP"
  target_id          = aws_organizations_account.default[each.value].id
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "admin_nested" {
  for_each = local.accounts_nested

  instance_arn       = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  principal_id       = aws_identitystore_group.admins.group_id
  principal_type     = "GROUP"
  target_id          = aws_organizations_account.nested[each.value].id
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "iam" {
  provider = aws.iam

  instance_arn       = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.identity_center_admin.arn
  principal_id       = aws_identitystore_group.iam_admins.group_id
  principal_type     = "GROUP"
  target_id          = aws_organizations_account.default["IAM"].id
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "security_readonly_admins" {
  provider = aws.iam

  for_each = toset([for account in local.accounts : account if account != "IAM"])

  instance_arn       = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
  principal_id       = aws_identitystore_group.security_admins.group_id
  principal_type     = "GROUP"
  target_id          = aws_organizations_account.default[each.value].id
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "security_readonly_admins_nested" {
  provider = aws.iam

  for_each = toset([for account in local.accounts_nested : account if account != "IAM"])

  instance_arn       = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
  principal_id       = aws_identitystore_group.security_admins.group_id
  principal_type     = "GROUP"
  target_id          = aws_organizations_account.nested[each.value].id
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "security_readonly_admins_security_audit" {
  provider = aws.iam

  instance_arn       = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
  principal_id       = aws_identitystore_group.security_admins.group_id
  principal_type     = "GROUP"
  target_id          = aws_organizations_account.security_audit.id
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "security_full_admins" {
  provider = aws.iam

  for_each = toset([for account in local.accounts : account if account != "IAM"])

  instance_arn       = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.security_full_admin.arn
  principal_id       = aws_identitystore_group.security_admins.group_id
  principal_type     = "GROUP"
  target_id          = aws_organizations_account.default[each.value].id
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "security_full_admins_security_audit" {
  provider = aws.iam

  instance_arn       = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.security_full_admin.arn
  principal_id       = aws_identitystore_group.security_admins.group_id
  principal_type     = "GROUP"
  target_id          = aws_organizations_account.security_audit.id
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "admin_management" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  principal_id       = aws_identitystore_group.admins.group_id
  principal_type     = "GROUP"
  target_id          = data.aws_caller_identity.current.account_id
  target_type        = "AWS_ACCOUNT"
}

# LAB: Permissions Boundaries Made Easy
resource "aws_ssoadmin_permissions_boundary_attachment" "iam_admin" {
  provider = aws.iam

  instance_arn       = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.identity_center_admin.arn

  permissions_boundary {
    customer_managed_policy_reference {
      name = aws_iam_policy.sso_permission_boundary.name
      path = "/"
    }
  }
}
