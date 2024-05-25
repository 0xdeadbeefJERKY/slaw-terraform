resource "aws_guardduty_detector" "default" {
  provider = aws.sa

  enable = true
}

resource "aws_guardduty_organization_admin_account" "default" {
  admin_account_id = aws_organizations_account.security_audit.id

  depends_on = [aws_guardduty_detector.default]
}

resource "aws_guardduty_organization_configuration" "default" {
  provider = aws.sa

  auto_enable_organization_members = "ALL"
  detector_id                      = aws_guardduty_detector.default.id

  datasources {
    kubernetes {
      audit_logs {
        enable = false
      }
    }

    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          auto_enable = false
        }
      }
    }

    s3_logs {
      auto_enable = false
    }
  }

  depends_on = [aws_guardduty_organization_admin_account.default]
}
