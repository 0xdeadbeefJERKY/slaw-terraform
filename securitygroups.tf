# use var.enable_test1_sgs to deploy the below resources

# LAB: Harnessing the Magic of Security Groups
resource "aws_security_group" "test_database" {
  count    = (var.enable_test1_sgs && var.enable_test1_vpc) ? 1 : 0
  provider = aws.test1

  name        = "Database"
  description = "Database security group"
  vpc_id      = aws_vpc.cloudslaw[0].id

  ingress {
    description = "Database access"
    cidr_blocks = ["123.4.5.6/32"]
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
  }

  ingress {
    description = "SSH access"
    cidr_blocks = ["10.0.0.0/16"]
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "test_backup" {
  count    = (var.enable_test1_sgs && var.enable_test1_vpc) ? 1 : 0
  provider = aws.test1

  name        = "Backup"
  description = "Database sends backups"
  vpc_id      = aws_vpc.cloudslaw[0].id

  ingress {
    description     = "Database backups"
    security_groups = [aws_security_group.test_database[0].id]
    protocol        = "tcp"
    from_port       = 2049
    to_port         = 2049
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
