output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = module.ec2.alb_dns_name
}

output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = module.rds.db_endpoint
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = module.s3.bucket_name
}
