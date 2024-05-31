# LAB: The Best Way to Start with AWS Security Hub

# NOTE: This requires a staged (2-step) deployment!
# 
# Background: When defining the Security Hub administrator account (delegated
# admin), there's no ability to programmatically disable the default security
# standards. Instead, we'll need to import these default standards into the 
# Terraform state file, then remove them to unsubscribe.
#
# To do this, run `terraform apply`, comment out both `import` blocks (below) 
# and the corresponding `aws_securityhub_standards_subscription` resources,
# and run `terraform apply` again.

data "aws_region" "sa" {
  provider = aws.sa
}

data "aws_caller_identity" "sa" {
  provider = aws.sa
}

resource "aws_securityhub_account" "default" {
  enable_default_standards = false
  auto_enable_controls     = false
}

resource "aws_securityhub_organization_admin_account" "security_audit" {
  admin_account_id = aws_organizations_account.security_audit.id
}

##############################################################################
# Run `terraform apply`, then comment out the below resources.
##############################################################################

# import {
#   provider = aws.sa

#   to = aws_securityhub_standards_subscription.aws_best_practices_100
#   id = "arn:aws:securityhub:${data.aws_region.sa.name}:${data.aws_caller_identity.sa.account_id}:subscription/aws-foundational-security-best-practices/v/1.0.0"
# }

# resource "aws_securityhub_standards_subscription" "aws_best_practices_100" {
#   provider = aws.sa

#   standards_arn = "arn:aws:securityhub:${data.aws_region.sa.name}::standards/aws-foundational-security-best-practices/v/1.0.0"
# }

# import {
#   provider = aws.sa

#   to = aws_securityhub_standards_subscription.cis
#   id = "arn:aws:securityhub:${data.aws_region.sa.name}:${data.aws_caller_identity.sa.account_id}:subscription/cis-aws-foundations-benchmark/v/1.2.0"
# }

# resource "aws_securityhub_standards_subscription" "cis" {
#   provider = aws.sa

#   standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
# }

##############################################################################
# End comment block
##############################################################################

resource "aws_securityhub_finding_aggregator" "default" {
  provider = aws.sa

  linking_mode = "ALL_REGIONS"

  depends_on = [aws_securityhub_organization_admin_account.security_audit]
}

resource "aws_securityhub_organization_configuration" "default" {
  provider = aws.sa

  auto_enable           = false
  auto_enable_standards = "NONE"

  organization_configuration {
    configuration_type = "CENTRAL"
  }

  depends_on = [aws_securityhub_finding_aggregator.default]
}

resource "aws_securityhub_configuration_policy" "default" {
  provider = aws.sa

  name = "configuration-policy-01"

  configuration_policy {
    service_enabled       = true
    enabled_standard_arns = []

    security_controls_configuration {
      enabled_control_identifiers = []
    }
  }

  depends_on = [aws_securityhub_organization_configuration.default]
}
