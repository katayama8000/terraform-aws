# API Gateway HTTP API（シンプル版）
resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "rust-lambda-api"
  protocol_type = "HTTP"
  description   = "HTTP API for Rust Lambda function"

  cors_configuration {
    allow_origins = ["*"] # 本番環境では具体的なドメインに変更してね！
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["content-type", "x-api-key", "authorization"]
    max_age       = 300
  }

  tags = {
    Name        = "Rust Lambda API"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# API Gateway Stage (デプロイ環境)
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.lambda_api.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 100  # 瞬間的なリクエスト数の上限
    throttling_rate_limit  = 50   # 1秒あたりのリクエスト数の上限
  }

  tags = {
    Name        = "Default Stage"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# Lambda統合設定
resource "aws_apigatewayv2_integration" "lambda" {
  api_id           = aws_apigatewayv2_api.lambda_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.rust_lambda.invoke_arn

  payload_format_version = "2.0"
}

# ルート設定（全てのリクエストをLambdaに）
resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# API GatewayがLambdaを呼び出せるようにする権限
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rust_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}

# ランダムなAPI Key生成（Lambda環境変数に設定）
resource "random_password" "api_key" {
  length  = 32
  special = false
}

# 出力：エンドポイントURL
output "api_endpoint" {
  description = "API Gateway endpoint URL (このURLをRNアプリで使ってね！)"
  value       = aws_apigatewayv2_api.lambda_api.api_endpoint
}

# 出力：API Key（Lambda内で検証する用）
output "api_key" {
  description = "API Key (RNアプリのヘッダーに 'x-api-key: この値' をセットしてね！)"
  value       = random_password.api_key.result
  sensitive   = true
}

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