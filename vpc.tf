# LAB: Journey to the Center of a VPC: Getting Started with Cloud Networks
resource "awsutils_default_vpc_deletion" "default" {
  provider = awsutils.test1
}

# Use var.enable_test1_vpc to deploy the below resources

# LAB: Build a VPC from Scratch
# Also used for the following labs:
#   * Harnessing the Magic of Security Groups
resource "aws_vpc" "cloudslaw" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "CloudSLAW"
  }
}

# LAB: Running Our First Instance (Finally!)
resource "aws_vpc_dhcp_options" "cloudslaw" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  domain_name         = "ec2.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    Name = "CloudSLAW-DHCP"
  }
}

resource "aws_vpc_dhcp_options_association" "cloudslaw" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  vpc_id          = aws_vpc.cloudslaw[0].id
  dhcp_options_id = aws_vpc_dhcp_options.cloudslaw[0].id
}

resource "aws_network_acl" "cloudslaw_public" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  vpc_id = aws_vpc.cloudslaw[0].id

  ingress {
    rule_no    = 100
    protocol   = -1
    from_port  = 0
    to_port    = 0
    action     = "allow"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no    = 100
    protocol   = -1
    from_port  = 0
    to_port    = 0
    action     = "allow"
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "CloudSLAW-Public-NACL"
  }
}

resource "aws_network_acl" "cloudslaw_private" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  vpc_id = aws_vpc.cloudslaw[0].id

  ingress {
    rule_no    = 100
    protocol   = -1
    from_port  = 0
    to_port    = 0
    action     = "allow"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no    = 100
    protocol   = -1
    from_port  = 0
    to_port    = 0
    action     = "allow"
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "CloudSLAW-Private-NACL"
  }
}

resource "aws_subnet" "cloudslaw_public_1" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  vpc_id                  = aws_vpc.cloudslaw[0].id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "slaw-public-1"
  }
}

resource "aws_subnet" "cloudslaw_public_2" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  vpc_id                  = aws_vpc.cloudslaw[0].id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "slaw-public-2"
  }
}

resource "aws_internet_gateway" "cloudslaw" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  vpc_id = aws_vpc.cloudslaw[0].id

  tags = {
    Name = "slaw-ig"
  }
}

resource "aws_route_table" "cloudslaw_public" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  vpc_id = aws_vpc.cloudslaw[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudslaw[0].id
  }
}

resource "aws_route_table_association" "cloudslaw_public_1" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  subnet_id      = aws_subnet.cloudslaw_public_1[0].id
  route_table_id = aws_route_table.cloudslaw_public[0].id
}

resource "aws_route_table_association" "cloudslaw_public_2" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  subnet_id      = aws_subnet.cloudslaw_public_2[0].id
  route_table_id = aws_route_table.cloudslaw_public[0].id
}

# LAB: NAT Your Way to Privacy (and Maybe Poverty)
resource "aws_subnet" "cloudslaw_private_1" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  vpc_id            = aws_vpc.cloudslaw[0].id
  availability_zone = "us-west-2a"
  cidr_block        = "10.0.3.0/24"

  tags = {
    Name = "slaw-private-1"
  }
}

resource "aws_subnet" "cloudslaw_private_2" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  vpc_id            = aws_vpc.cloudslaw[0].id
  availability_zone = "us-west-2a"
  cidr_block        = "10.0.4.0/24"

  tags = {
    Name = "slaw-private-2"
  }
}

# LAB: Running Our First Instance (Finally!)
resource "aws_network_acl_association" "cloudslaw_public1" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  network_acl_id = aws_network_acl.cloudslaw_public[0].id
  subnet_id      = aws_subnet.cloudslaw_public_1[0].id
}

resource "aws_network_acl_association" "cloudslaw_public2" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  network_acl_id = aws_network_acl.cloudslaw_public[0].id
  subnet_id      = aws_subnet.cloudslaw_public_2[0].id
}

resource "aws_network_acl_association" "cloudslaw_private1" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  network_acl_id = aws_network_acl.cloudslaw_public[0].id
  subnet_id      = aws_subnet.cloudslaw_private_1[0].id
}

resource "aws_network_acl_association" "cloudslaw_private2" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  network_acl_id = aws_network_acl.cloudslaw_public[0].id
  subnet_id      = aws_subnet.cloudslaw_private_2[0].id
}

resource "aws_security_group" "private" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  name        = "CloudSLAW-Private-SG"
  description = "Private security group with no inbound rules and outbound access to all IPs"
  vpc_id      = aws_vpc.cloudslaw[0].id

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# LAB: Keep Private Subnets Private with VPC Endpoints
resource "aws_security_group" "endpoints" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  name        = "Endpoints"
  description = "Security group allowing all outbound traffic and inbound HTTPS from VPC"
  vpc_id      = aws_vpc.cloudslaw[0].id

  ingress {
    description = "Intra-VPC HTTPS"
    cidr_blocks = ["10.0.0.0/16"]
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route_table" "cloudslaw_private" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  vpc_id = aws_vpc.cloudslaw[0].id
}

resource "aws_route_table_association" "cloudslaw_private_1" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  subnet_id      = aws_subnet.cloudslaw_private_1[0].id
  route_table_id = aws_route_table.cloudslaw_private[0].id
}

resource "aws_route_table_association" "cloudslaw_private_2" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  subnet_id      = aws_subnet.cloudslaw_private_2[0].id
  route_table_id = aws_route_table.cloudslaw_private[0].id
}

# LAB: Let's Get Hacked! Public SSH Edition
resource "aws_vpc" "exposed" {
  count    = var.enable_ssh_exposed ? 1 : 0
  provider = aws.test1

  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "Exposed"
  }
}

resource "aws_internet_gateway" "exposed" {
  count    = var.enable_ssh_exposed ? 1 : 0
  provider = aws.test1

  vpc_id = aws_vpc.exposed[0].id

  tags = {
    Name = "exposed-ig"
  }
}

resource "aws_subnet" "exposed" {
  count    = var.enable_ssh_exposed ? 1 : 0
  provider = aws.test1

  vpc_id                  = aws_vpc.exposed[0].id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Exposed-Public"
  }
}

resource "aws_route_table" "exposed_public" {
  count    = var.enable_ssh_exposed ? 1 : 0
  provider = aws.test1

  vpc_id = aws_vpc.exposed[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.exposed[0].id
  }
}

resource "aws_route_table_association" "exposed_public" {
  count    = var.enable_ssh_exposed ? 1 : 0
  provider = aws.test1

  subnet_id      = aws_subnet.exposed[0].id
  route_table_id = aws_route_table.exposed_public[0].id
}

resource "aws_security_group" "exposed_public" {
  count    = var.enable_ssh_exposed ? 1 : 0
  provider = aws.test1

  name        = "Allow SSH"
  description = "Allow SSH access from anywhere"
  vpc_id      = aws_vpc.exposed[0].id

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
