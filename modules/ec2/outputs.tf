output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.this.dns_name
}

output "ec2_sg_id" {
  description = "The ID of the EC2 security group"
  value       = aws_security_group.ec2_sg.id
}
