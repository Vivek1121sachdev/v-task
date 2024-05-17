output "execution_arn" {
  value = aws_api_gateway_rest_api.api-gw.execution_arn
}

output "api-gw-endpoint"{
  value = aws_api_gateway_deployment.apigw_deployment.invoke_url
}

output "stage_name" {
  value = aws_api_gateway_stage.apigw_stage.stage_name
}