output "lambda_invoke_arn" {
  value = aws_lambda_function.lambda-function.invoke_arn
}

output "security_group" {
  value = aws_security_group.lambda_sg.id
}