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
