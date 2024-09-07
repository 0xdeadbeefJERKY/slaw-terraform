# LAB: Keep Private Subnets Private with VPC Endpoints
resource "aws_vpc_endpoint" "ssm" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  vpc_id              = aws_vpc.cloudslaw[0].id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.endpoints[0].id]
  subnet_ids          = [aws_subnet.cloudslaw_private_1[0].id]

  dns_options {
    dns_record_ip_type = "ipv4"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  vpc_id              = aws_vpc.cloudslaw[0].id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.endpoints[0].id]
  subnet_ids          = [aws_subnet.cloudslaw_private_1[0].id]

  dns_options {
    dns_record_ip_type = "ipv4"
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  vpc_id              = aws_vpc.cloudslaw[0].id
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.endpoints[0].id]
  subnet_ids          = [aws_subnet.cloudslaw_private_1[0].id]

  dns_options {
    dns_record_ip_type = "ipv4"
  }
}
