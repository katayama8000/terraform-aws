# API Gateway HTTP API for Expo Push Notification API
resource "aws_apigatewayv2_api" "expo_push_notification_api" {
  name          = "expo-push-notification-api"
  protocol_type = "HTTP"
  description   = "HTTP API for Expo Push Notification API"

  cors_configuration {
    allow_origins = ["*"] # 本番環境では具体的なドメインに変更してください
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["content-type", "x-api-key"]
    max_age       = 300
  }

  tags = {
    Name        = "Expo Push Notification API"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# API Gateway Stage
resource "aws_apigatewayv2_stage" "expo_push_notification_api_default" {
  api_id      = aws_apigatewayv2_api.expo_push_notification_api.id
  name        = "$default"
  auto_deploy = true
}

# Lambda Integration
resource "aws_apigatewayv2_integration" "expo_push_notification_api_lambda" {
  api_id           = aws_apigatewayv2_api.expo_push_notification_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.expo_push_notification_api.invoke_arn
  payload_format_version = "2.0"
}

# Route for POST requests
resource "aws_apigatewayv2_route" "expo_push_notification_api_post" {
  api_id    = aws_apigatewayv2_api.expo_push_notification_api.id
  route_key = "POST /"
  target    = "integrations/${aws_apigatewayv2_integration.expo_push_notification_api_lambda.id}"
}

# Route for scheduled task POST requests
resource "aws_apigatewayv2_route" "expo_push_notification_api_post_scheduled" {
  api_id    = aws_apigatewayv2_api.expo_push_notification_api.id
  route_key = "POST /scheduled"
  target    = "integrations/${aws_apigatewayv2_integration.expo_push_notification_api_lambda.id}"
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "expo_push_notification_api_gateway" {
  statement_id  = "AllowAPIGatewayInvokeExpoPush"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.expo_push_notification_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.expo_push_notification_api.execution_arn}/*/*"
}

# API Key
resource "random_password" "expo_push_notification_api_key" {
  length  = 32
  special = false
}

# Outputs
output "expo_push_notification_api_endpoint" {
  description = "API Gateway endpoint URL for Expo Push Notification"
  value       = aws_apigatewayv2_api.expo_push_notification_api.api_endpoint
}

output "expo_push_notification_api_key" {
  description = "API Key for Expo Push Notification"
  value       = random_password.expo_push_notification_api_key.result
  sensitive   = true
}