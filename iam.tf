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
