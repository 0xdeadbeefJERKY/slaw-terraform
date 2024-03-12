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

# LAB: Assume the Role!
provider "aws" {
  alias  = "security-audit"
  region = var.region

  assume_role {
    role_arn     = "arn:aws:iam::${aws_organizations_account.security_audit.id}:role/OrganizationAccountAccessRole"
    session_name = "tf-security-audit-org"
  }
}
