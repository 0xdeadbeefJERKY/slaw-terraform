# LAB: Running Our First Instance (Finally!)
data "aws_ami" "amazon_linux" {
  count    = var.enable_ssh_exposed ? 1 : 0
  provider = aws.test1

  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  owners = ["amazon"]
}

resource "aws_instance" "cloudslaw" {
  count    = var.enable_test1_vpc ? 2 : 0
  provider = aws.test1

  ami                         = "ami-083da6537e6c95ec1" # cloudslaw-lab34
  instance_type               = "t2.micro"
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ssm[0].name
  subnet_id                   = module.test_vpc[0].private_subnets[0].id
  vpc_security_group_ids      = [aws_security_group.private[0].id]

  tags = {
    Name = "SLAW-${count.index}"
  }
}

# LAB: Let's Get Hacked! Public SSH Edition
resource "aws_instance" "exposed" {
  count    = var.enable_ssh_exposed ? 1 : 0
  provider = aws.test1

  ami                         = data.aws_ami.amazon_linux[0].image_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = module.test_vpc[0].public_subnets[0].id
  vpc_security_group_ids      = [aws_security_group.exposed_public[0].id]

  tags = {
    Name = "HackMePlease"
  }
}
