# LAB: Journey to the Center of a VPC: Getting Started with Cloud Networks
resource "awsutils_default_vpc_deletion" "default" {
  provider = awsutils.test1
}

# Uncomment everything below this line, run `terraform apply`, then add the
# comments back and run `terraform apply` again.

# # LAB: Build a VPC from Scratch
# resource "aws_vpc" "cloudslaw" {
#   provider = aws.test1

#   cidr_block = "10.0.0.0/16"

#   tags = {
#     Name = "CloudSLAW"
#   }
# }

# resource "aws_subnet" "cloudslaw_public_1" {
#   provider = aws.test1

#   vpc_id                  = aws_vpc.cloudslaw.id
#   availability_zone       = "us-west-2a"
#   cidr_block              = "10.0.1.0/24"
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "slaw-public-1"
#   }
# }

# resource "aws_subnet" "cloudslaw_public_2" {
#   provider = aws.test1

#   vpc_id                  = aws_vpc.cloudslaw.id
#   availability_zone       = "us-west-2a"
#   cidr_block              = "10.0.2.0/24"
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "slaw-public-2"
#   }
# }

# resource "aws_internet_gateway" "cloudslaw" {
#   provider = aws.test1

#   vpc_id = aws_vpc.cloudslaw.id

#   tags = {
#     Name = "slaw-ig"
#   }
# }

# resource "aws_route_table" "cloudslaw_public" {
#   provider = aws.test1

#   vpc_id = aws_vpc.cloudslaw.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.cloudslaw.id
#   }
# }

# resource "aws_route_table_association" "cloudslaw_public_1" {
#   provider = aws.test1

#   subnet_id      = aws_subnet.cloudslaw_public_1.id
#   route_table_id = aws_route_table.cloudslaw_public.id
# }

# resource "aws_route_table_association" "cloudslaw_public_2" {
#   provider = aws.test1

#   subnet_id      = aws_subnet.cloudslaw_public_2.id
#   route_table_id = aws_route_table.cloudslaw_public.id
# }

# # LAB: NAT Your Way to Privacy (and Maybe Poverty)
# resource "aws_subnet" "cloudslaw_private_1" {
#   provider = aws.test1

#   vpc_id            = aws_vpc.cloudslaw.id
#   availability_zone = "us-west-2a"
#   cidr_block        = "10.0.3.0/24"

#   tags = {
#     Name = "slaw-private-1"
#   }
# }

# resource "aws_subnet" "cloudslaw_private_2" {
#   provider = aws.test1

#   vpc_id            = aws_vpc.cloudslaw.id
#   availability_zone = "us-west-2a"
#   cidr_block        = "10.0.4.0/24"

#   tags = {
#     Name = "slaw-private-2"
#   }
# }

# resource "aws_eip" "nat" {
#   provider = aws.test1
# }

# resource "aws_nat_gateway" "default" {
#   provider = aws.test1

#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.cloudslaw_public_1.id

#   tags = {
#     Name = "slaw-nat"
#   }
# }

# resource "aws_route_table" "cloudslaw_private" {
#   provider = aws.test1

#   vpc_id = aws_vpc.cloudslaw.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.default.id
#   }
# }

# resource "aws_route_table_association" "cloudslaw_private_1" {
#   provider = aws.test1

#   subnet_id      = aws_subnet.cloudslaw_private_1.id
#   route_table_id = aws_route_table.cloudslaw_private.id
# }

# resource "aws_route_table_association" "cloudslaw_private_2" {
#   provider = aws.test1

#   subnet_id      = aws_subnet.cloudslaw_private_2.id
#   route_table_id = aws_route_table.cloudslaw_private.id
# }
