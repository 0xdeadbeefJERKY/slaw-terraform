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

resource "aws_identitystore_group_membership" "default" {
  group_id          = aws_identitystore_group.admins.group_id
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

resource "aws_ssoadmin_account_assignment" "admin_log_archive" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  principal_id       = aws_identitystore_group.admins.group_id
  principal_type     = "GROUP"
  target_id          = aws_organizations_account.default["LogArchive"].id
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
