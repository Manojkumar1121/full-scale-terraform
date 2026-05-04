resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP inbound traffic to ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow HTTP inbound traffic from ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}

resource "aws_lb" "this" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "app-alb"
  }
}

resource "aws_lb_target_group" "this" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
    port = "traffic-port"
  }

  tags = {
    Name = "app-tg"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "this" {
  name_prefix   = "app-lt-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(<<EOF
#!/bin/bash
amazon-linux-extras install nginx1 -y
systemctl start nginx
systemctl enable nginx
echo "Hello from $(hostname -f)" > /usr/share/nginx/html/index.html
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "app-instance"
    }
  }
}

resource "aws_autoscaling_group" "this" {
  name                = "app-asg"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.this.arn]

  min_size         = var.environment == "prod" ? 2 : 1
  max_size         = var.environment == "prod" ? 5 : 1
  desired_capacity = var.environment == "prod" ? 2 : 1

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "app-asg-instance"
    propagate_at_launch = true
  }
}
