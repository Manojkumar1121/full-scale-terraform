variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "environment" {
  description = "Environment name (dev or prod)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}
