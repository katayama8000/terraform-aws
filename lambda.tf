

# Lambda Function for Expo Push Notification API
resource "aws_lambda_function" "expo_push_notification_api" {
  function_name    = "expo-push-notification-api"
  role             = aws_iam_role.expo_push_notification_api_role.arn
  handler          = "bootstrap"
  runtime          = "provided.al2023"
  filename         = "lambda_placeholder.zip"
  source_code_hash = "placeholder"

  timeout       = 30
  memory_size   = 128
  architectures = ["arm64"]
  publish       = false

  environment {
    variables = {
      API_KEY            = random_password.expo_push_notification_api_key.result
      SSM_PARAMETER_PATH = "/expo-push-api/"
    }
  }

  ephemeral_storage {
    size = 512
  }

  tracing_config {
    mode = "PassThrough"
  }

  logging_config {
    log_format = "Text"
    log_group  = "/aws/lambda/expo-push-notification-api"
  }

  tags = {
    Name        = "Expo Push Notification API"
    Environment = "Prd"
    ManagedBy   = "Terraform"
  }

  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash,
    ]
  }
}