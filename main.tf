#----------------#
# Provider Block #
#----------------#

provider "aws" {
  region = var.region
}

#------------#
# S3 Backend #
#------------#

terraform {
  backend "s3" {
    bucket  = "lambda-ec2-backend"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

#------------#
# VPC Module #
#------------#

module "vpc" {
  source = "./modules/vpc"
  cidr_block = "20.0.0.0/16"
  public_cidr = "20.0.1.0/24"
  private_cidr = "20.0.2.0/24"
  az = "us-east-1a"
}

#--------------#
# EC2 Instance #
#--------------#

module "ec2" {
  source = "./modules/ec2"
  vpc_id =  module.vpc.vpc_id
  public_subnet = module.vpc.public_subnet
  private_subnet = module.vpc.private_subnet
  lambda_sg = module.lambda.security_group
}

#------------#
# ECR Module #
#------------#

module "ecr" {
  source = "./modules/ECR"
}

#---------------#
# Lambda Module #
#---------------#

module "lambda" {
  source = "./modules/lambda"
  vpc_id = module.vpc.vpc_id
  function_name = "v_task_lambda_function"
  lambda_timeout = 300
  image-uri = "${module.ecr.repository_url}:${data.aws_ecr_image.image.image_tags[0]}"
  private_subnet = module.vpc.private_subnet
  path_parts = local.resources
  execution_arn = module.api-gw.execution_arn
  host_ip = module.ec2.private_ec2_private_ip
  user = "root"
  password = "password"
  database_name = "aws"
}


#---------------#
# API-GW Module #
#---------------#

module "api-gw" {
  source = "./modules/api-gw"
  lambda_invoke_arn = module.lambda.lambda_invoke_arn
  resource = local.resources
}


#-----------#
# S3 Bucket #
#-----------#

resource "aws_s3_bucket" "v_task_bucket" {
    bucket = "v-task-objects"
    tags = {
        Name = "v-task-objects"
    }
}

resource "aws_s3_object" "bucket_objects" {
  bucket = aws_s3_bucket.v_task_bucket.id
  
  for_each = fileset("objects","**/*.*")
  key = each.value
  source = "objects/${each.value}"
  content_type = each.value
}