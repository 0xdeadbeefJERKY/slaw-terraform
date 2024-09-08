# LAB: Replace SSH with Session Manager

# In some cases, this SSM document will already exist
import {
  provider = aws.test1

  to = aws_ssm_document.session_manager_prefs
  id = "SSM-SessionManagerRunShell"
}

# https://docs.aws.amazon.com/systems-manager/latest/userguide/getting-started-create-preferences-cli.html
# https://github.com/hashicorp/terraform-provider-aws/issues/6121#issuecomment-671749633
resource "aws_ssm_document" "session_manager_prefs" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Document to hold regional settings for Session Manager"
    sessionType   = "Standard_Stream"
    inputs = {
      s3EncryptionEnabled         = true
      s3BucketName                = aws_s3_bucket.ssm_logs[0].bucket
      cloudWatchEncryptionEnabled = true
      cloudWatchStreamingEnabled  = true
      idleSessionTimeout          = "20"
      runAsEnabled                = true
      runAsDefaultUser            = "ec2-user"
    }
  })
}
