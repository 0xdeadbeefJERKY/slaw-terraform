data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  network_acls = {
    default_inbound = [
      {
        rule_no    = 900
        action     = "allow"
        from_port  = 443
        to_port    = 443
        protocol   = "tcp"
        cidr_block = "0.0.0.0/0"
      },
    ]
    default_outbound = [
      {
        rule_no    = 900
        action     = "allow"
        from_port  = 0
        to_port    = 0
        protocol   = -1
        cidr_block = "0.0.0.0/0"
      },
    ]
  }
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.14.0"

  name = "CloudLSAW"
  cidr = var.cidr_block

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(var.cidr_block, 8, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.cidr_block, 8, k + 4)]

  private_subnet_names = ["slaw-private-1", "slaw-private-2"]
  public_subnet_names  = ["slaw-public-1", "slaw-public-2"]

  manage_default_network_acl = true

  default_network_acl_ingress = local.network_acls["default_inbound"]
  default_network_acl_egress  = local.network_acls["default_outbound"]

  manage_default_security_group  = true
  default_security_group_ingress = [{}]
  default_security_group_egress  = [{}]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dhcp_options              = true
  dhcp_options_domain_name         = "ec2.internal"
  dhcp_options_domain_name_servers = ["AmazonProvidedDNS"]
}

################################################################################
# VPC Endpoints Module
################################################################################

module "vpc_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id                     = module.vpc.vpc_id
  create_security_group      = true
  security_group_description = "Security group allowing all outbound traffic and inbound HTTPS from VPC"

  security_group_rules = {
    ingress_https = {
      description = "Intra-VPC HTTPS"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }

  endpoints = {
    s3 = {
      service             = "s3"
      private_dns_enabled = true
      vpc_endpoint_type   = "Gateway"
      policy              = data.aws_iam_policy_document.s3_endpoint.json
      subnet_id           = module.vpc.private_subnets

      dns_options = {
        dns_record_ip_type = "ipv4"
      }
    },
    ec2messages = {
      service             = "ec2messages"
      private_dns_enabled = true
      subnet_id           = module.vpc.private_subnets

      dns_options = {
        dns_record_ip_type = "ipv4"
      }
    },
    ssmmessages = {
      service             = "ssmmessages"
      private_dns_enabled = true
      subnet_id           = module.vpc.private_subnets

      dns_options = {
        dns_record_ip_type = "ipv4"
      }
    },
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
      subnet_id           = module.vpc.private_subnets

      dns_options = {
        dns_record_ip_type = "ipv4"
      }
    },
  }
}

################################################################################
# Supporting Resources
################################################################################

data "aws_iam_policy_document" "s3_endpoint" {
  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}
