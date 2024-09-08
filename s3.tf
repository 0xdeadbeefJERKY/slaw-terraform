# LAB: Enabling Logs in Session Manager
resource "aws_s3_bucket" "ssm_logs" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  bucket = "session-manager-logs-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_versioning" "ssm_logs" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  bucket = aws_s3_bucket.ssm_logs[0].bucket

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ssm_logs" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  bucket = aws_s3_bucket.ssm_logs[0].bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "ssm_logs" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  bucket                  = aws_s3_bucket.ssm_logs[0].bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
