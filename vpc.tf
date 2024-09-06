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

  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "CloudSLAW"
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

resource "aws_eip" "nat" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1
}

resource "aws_nat_gateway" "default" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.cloudslaw_public_1[0].id

  tags = {
    Name = "slaw-nat"
  }
}

resource "aws_route_table" "cloudslaw_private" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  vpc_id = aws_vpc.cloudslaw[0].id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.default[0].id
  }
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
