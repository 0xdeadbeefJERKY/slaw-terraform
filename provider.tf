terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = "~> 1.6.6"
}

provider "aws" {
  region = var.region
}

# LAB: Enable GuardDuty the Right Way
provider "aws" {
  alias  = "sa"
  region = var.region

  assume_role {
    role_arn     = "arn:aws:iam::${aws_organizations_account.security_audit.id}:role/OrganizationAccountAccessRole"
    session_name = "tf-security-audit-org"
  }
}

# LAB: Assume the Role!
provider "aws" {
  alias  = "security-audit"
  region = var.region

  assume_role {
    # LAB: OUs, SCPs and Root User Account Recovery
    # Continue using the original SecurityAudit role that now resides in the 
    # LogArchive account
    role_arn     = "arn:aws:iam::${aws_organizations_account.default["LogArchive"].id}:role/OrganizationAccountAccessRole"
    session_name = "tf-security-audit-org"
  }
}

# LAB: Creating Security Team Permissions in IAM Identity Center
provider "aws" {
  alias  = "iam"
  region = var.region

  assume_role {
    role_arn     = "arn:aws:iam::${aws_organizations_account.default["IAM"].id}:role/OrganizationAccountAccessRole"
    session_name = "tf-iam-org"
  }
}
