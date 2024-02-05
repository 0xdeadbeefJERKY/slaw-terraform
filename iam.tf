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
