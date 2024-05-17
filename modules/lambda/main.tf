// Security Group for Lambda //
resource "aws_security_group" "lambda_sg" {
  name        = "Lambda-SecurityGroup"
  description = "Security group for Lambda Function"

  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all incomming traffic
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "v_task_lambda_sg"
  }
}


// Lambda Function //
resource "aws_lambda_function" "lambda-function" {
  function_name = var.function_name
  timeout       = var.lambda_timeout
  image_uri     = var.image-uri
  package_type  = "Image"
  role          = aws_iam_role.v_task_lambda_role.arn
  vpc_config {
    subnet_ids         = [var.private_subnet]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      "host_ip" : var.host_ip,
      "db_user" : var.user,
      "db_password" : var.password,
      "db_name" : var.database_name
    }
  }
}
