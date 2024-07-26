# LAB: Journey to the Center of a VPC: Getting Started with Cloud Networks
resource "aws_default_vpc" "default" {
  provider = aws.test1

  count         = 0
  force_destroy = true
}
