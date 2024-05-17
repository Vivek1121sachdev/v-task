// ECR Iamge //
data "aws_ecr_image" "image" {
  repository_name = module.ecr.repository_name
  most_recent     = true
}
locals {
  resources = {
    s3 = "ANY",
    dynamodb = "ANY"
  }  
}
