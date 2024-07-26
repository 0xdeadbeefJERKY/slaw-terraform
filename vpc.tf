# LAB: Journey to the Center of a VPC: Getting Started with Cloud Networks
resource "awsutils_default_vpc_deletion" "default" {
  provider = awsutils.test1
}

# LAB: Build a VPC from Scratch
resource "aws_vpc" "cloudslaw" {
  provider = aws.test1

  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "CloudSLAW"
  }
}

resource "aws_subnet" "cloudlsaw_public_1" {
  provider = aws.test1

  vpc_id            = aws_vpc.cloudslaw.id
  availability_zone = "us-west-2a"
  cidr_block        = "10.0.1.0/24"

  tags = {
    Name = "slaw-public-1"
  }
}

resource "aws_subnet" "cloudlsaw_public_2" {
  provider = aws.test1

  vpc_id            = aws_vpc.cloudslaw.id
  availability_zone = "us-west-2a"
  cidr_block        = "10.0.2.0/24"

  tags = {
    Name = "slaw-public-2"
  }
}

resource "aws_internet_gateway" "cloudslaw" {
  provider = aws.test1

  vpc_id = aws_vpc.cloudslaw.id

  tags = {
    Name = "slaw-ig"
  }
}

resource "aws_route_table" "cloudlsaw_public" {
  provider = aws.test1

  vpc_id = aws_vpc.cloudslaw.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudslaw.id
  }
}

resource "aws_route_table_association" "cloudslaw_public_1" {
  provider = aws.test1

  subnet_id      = aws_subnet.cloudlsaw_public_1.id
  route_table_id = aws_route_table.cloudlsaw_public.id
}

resource "aws_route_table_association" "cloudslaw_public_2" {
  provider = aws.test1

  subnet_id      = aws_subnet.cloudlsaw_public_2.id
  route_table_id = aws_route_table.cloudlsaw_public.id
}
