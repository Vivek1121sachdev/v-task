// API Gateway //
resource "aws_api_gateway_rest_api" "api-gw" {
  name = "v_task_api_gw"
}

// API Gateway Resources //
resource "aws_api_gateway_resource" "resources" {
  for_each = var.resource

  parent_id   = aws_api_gateway_rest_api.api-gw.root_resource_id
  path_part   = each.key
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
}

// API Gateway Methods //
resource "aws_api_gateway_method" "methods" {
  for_each = var.resource

  rest_api_id   = aws_api_gateway_rest_api.api-gw.id
  resource_id   = aws_api_gateway_resource.resources[each.key].id
  http_method   = each.value
  authorization = "NONE"
}

// API Gateway Method Resource Integration //
resource "aws_api_gateway_integration" "method-resource-integration" {
  for_each = var.resource

  rest_api_id             = aws_api_gateway_rest_api.api-gw.id
  resource_id             = aws_api_gateway_resource.resources[each.key].id
  http_method             = aws_api_gateway_method.methods[each.key].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

// API Gateway Deployment //
resource "aws_api_gateway_deployment" "apigw_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api-gw.body))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.methods,
    aws_api_gateway_integration.method-resource-integration
   ]
}

// API Gateway Stage //
resource "aws_api_gateway_stage" "apigw_stage" {
  deployment_id = aws_api_gateway_deployment.apigw_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api-gw.id
  stage_name    = "dev"
}