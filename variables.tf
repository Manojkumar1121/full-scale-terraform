variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name (dev or prod)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "db_engine" {
  description = "Database engine"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "s3_bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
