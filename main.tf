terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "TerraformTask"
    }
  }
}

module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
}

module "ec2" {
  source             = "./modules/ec2"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  environment        = var.environment
  instance_type      = var.instance_type
}

module "rds" {
  source             = "./modules/rds"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  ec2_security_group = module.ec2.ec2_sg_id
  db_engine          = var.db_engine
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
}

module "s3" {
  source         = "./modules/s3"
  s3_bucket_name = var.s3_bucket_name
}
