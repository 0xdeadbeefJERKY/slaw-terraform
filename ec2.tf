# LAB: Running Our First Instance (Finally!)
data "aws_ami" "amazon_linux" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  owners = ["amazon"]
}

resource "aws_instance" "cloudslaw" {
  count    = var.enable_test1_vpc ? 1 : 0
  provider = aws.test1

  ami                         = data.aws_ami.amazon_linux[0].id
  instance_type               = "t2.micro"
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ssm[0].name
  subnet_id                   = aws_subnet.cloudslaw_private_1[0].id
  security_groups             = [aws_security_group.private[0].id]

  tags = {
    Name = "SLAW"
  }
}
