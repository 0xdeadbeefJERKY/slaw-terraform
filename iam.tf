# LAB: Create Your First Admin User
resource "aws_iam_group" "administrators" {
  name = "Administrators"
}

resource "aws_iam_group_policy_attachment" "administrators" {
  group      = aws_iam_group.administrators.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Ironically, the initial admin user will need to be manually created first, 
# used to run `terraform apply`, then import the manually created resources.
resource "aws_iam_user" "administrators" {
  for_each = toset(var.admin_users)

  name = each.value
}

resource "aws_iam_user_group_membership" "administrators" {
  for_each = toset(var.admin_users)

  user   = each.value
  groups = [aws_iam_group.administrators.name]
}

# LAB: Create Your First IAM Role
data "aws_iam_policy_document" "ssm_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ssm" {
  name               = "SSMInstance"
  assume_role_policy = data.aws_iam_policy_document.ssm_trust_policy.json
}

data "aws_iam_policy" "ssm" {
  name = "AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm.name
  policy_arn = data.aws_iam_policy.ssm.arn
}

# LAB: Write a Simple IAM Policy
data "aws_iam_policy_document" "cloudtrail_rw" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = ["${aws_s3_bucket.default.arn}/*"]
  }
}

resource "aws_iam_policy" "cloudtrail_rw" {
  name        = "CloudtrailReadWrite"
  description = "Allow read and write access to our main CloudTrail bucket."
  policy      = data.aws_iam_policy_document.cloudtrail_rw.json
}

# LAB: PBAC and ABAC? Write an Intermediate AWS IAM Policy
data "http" "my_public_ip" {
  url = "https://icanhazip.com"
}

data "aws_iam_policy_document" "test_ec2_actions" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:StartInstances",
      "ec2:StopInstances",
      "ec2:Describe*"
    ]
  }

  statement {
    effect    = "Deny"
    resources = ["*"]
    actions   = ["ec2:TerminateInstances"]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = [chomp(data.http.my_public_ip.response_body)]
    }
  }
}

resource "aws_iam_policy" "delete_me_now_please" {
  provider = aws.test1

  name   = "DeleteMePleaseNow"
  policy = data.aws_iam_policy_document.test_ec2_actions.json
}

# LAB: Permissions Boundaries Made Easy
data "aws_iam_policy_document" "iam_admin_perm_boundary" {
  version = "2012-10-17"

  statement {
    sid       = "AllowAllActions"
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }

  statement {
    sid       = "DenyActionsOnSpecificPermissionSet"
    effect    = "Deny"
    actions   = ["*"]
    resources = [aws_ssoadmin_permission_set.identity_center_admin.arn]
  }
}

resource "aws_iam_policy" "sso_permission_boundary" {
  provider = aws.iam

  name        = "SSOPermissionBoundary"
  policy      = data.aws_iam_policy_document.iam_admin_perm_boundary.json
  description = "Restricts an IAM Identity Center administrator from escalating privileges"
}

# LAB: Running Our First Instance (Finally!)
resource "aws_iam_role" "ssm_client" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  name               = "SSMClient"
  assume_role_policy = data.aws_iam_policy_document.ssm_trust_policy.json
}

resource "aws_iam_role_policy_attachment" "ssm_client" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  role       = aws_iam_role.ssm_client[0].name
  policy_arn = data.aws_iam_policy.ssm.arn
}

resource "aws_iam_instance_profile" "ssm" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  name = "SSMClient"
  role = aws_iam_role.ssm_client[0].name
}
