resource "aws_db_subnet_group" "this" {
  name       = "app-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "app-db-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow inbound traffic from EC2"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Traffic from EC2"
    from_port       = var.db_engine == "postgres" ? 5432 : 3306
    to_port         = var.db_engine == "postgres" ? 5432 : 3306
    protocol        = "tcp"
    security_groups = [var.ec2_security_group]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

resource "aws_db_instance" "this" {
  identifier             = "app-db-instance"
  engine                 = var.db_engine
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "app-db-instance"
  }
}
