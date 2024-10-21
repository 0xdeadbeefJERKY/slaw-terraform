module "test_vpc" {
  count = var.enable_test1_vpc ? 1 : 0
  providers = {
    aws = aws.test1
  }

  source = "./modules/vpc"
}

# LAB: Journey to the Center of a VPC: Getting Started with Cloud Networks
resource "awsutils_default_vpc_deletion" "default" {
  provider = awsutils.test1
}

resource "aws_security_group" "private" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  name        = "CloudSLAW-Private-SG"
  description = "Private security group with no inbound rules and outbound access to all IPs"
  vpc_id      = module.test_vpc[0].vpc_id

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "exposed_public" {
  count    = var.enable_ssh_exposed ? 1 : 0
  provider = aws.test1

  name        = "Allow SSH"
  description = "Allow SSH access from anywhere"
  vpc_id      = module.test_vpc[0].vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AllowSSHSecurityGroup"
  }
}
