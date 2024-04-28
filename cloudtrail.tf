# LAB: Turning on CloudTrail
resource "aws_s3_bucket" "default" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.default.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "default" {
  statement {
    sid = "AWSCloudTrailAclCheck"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.default.arn]

    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/default"]
    }
  }

  statement {
    sid = "AWSCloudTrailWrite"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.default.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/default"]
    }
  }
}

resource "aws_s3_bucket_policy" "default" {
  bucket = aws_s3_bucket.default.id
  policy = data.aws_iam_policy_document.default.json
}

resource "aws_cloudtrail" "default" {
  name                       = "default"
  enable_log_file_validation = true
  is_multi_region_trail      = true
  # LAB: Enabling the Org Trail
  s3_bucket_name        = aws_s3_bucket.cloudtrail_security_audit.id
  is_organization_trail = true

  depends_on = [aws_s3_bucket_policy.default]
}

# LAB: Assume the Role!
resource "aws_s3_bucket" "cloudtrail_security_audit" {
  provider = aws.security-audit
  bucket   = var.security_audit_bucket_name
}

# LAB: Secure that Bucket!
data "aws_iam_policy_document" "security_audit" {
  version = "2012-10-17"

  statement {
    sid    = "AWSCloudTrailAclCheck20150319"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail_security_audit.arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudtrail.default.arn]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite20150319"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail_security_audit.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudtrail.default.arn]
    }
  }

  statement {
    sid    = "AWSCloudTrailOrganizationWrite20150319"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail_security_audit.arn}/AWSLogs/${aws_organizations_organization.default.id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudtrail.default.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "security_audit" {
  provider = aws.security-audit
  bucket   = aws_s3_bucket.cloudtrail_security_audit.id
  policy   = data.aws_iam_policy_document.security_audit.json
}

# LAB: On the Meaning of Life(cycles), Versions, and Ransomware
resource "aws_s3_bucket_lifecycle_configuration" "delete_old_objects" {
  provider = aws.security-audit
  bucket   = aws_s3_bucket.cloudtrail_security_audit.id

  rule {
    id     = "DeleteOldObjects"
    status = "Enabled"

    expiration {
      days = var.cloudtrail_s3_object_expiration_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.cloudtrail_s3_object_expiration_days
    }
  }
}
