# Lambda Function
resource "aws_lambda_function" "rust_lambda" {
  function_name    = "my-rust-lambda"
  role             = aws_iam_role.lambda_role.arn
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
      API_KEY = random_password.api_key.result
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
    log_group  = "/aws/lambda/my-rust-lambda"
  }

  tags = {
    Name        = "My Rust Lambda"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }

  # ignore changes because this lamda is deployed cargo-lambda tooling outside terraform
  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash,
    ]
  }
}

# Lambda Function URL（AWS_IAM認証付き）
resource "aws_lambda_function_url" "rust_lambda_url" {
  function_name      = aws_lambda_function.rust_lambda.function_name
  authorization_type = "AWS_IAM" # 認証必須！署名付きリクエストのみ受け付ける

  cors {
    allow_origins = ["*"] # 本番環境では具体的なドメインに変更してね！
    allow_methods = ["*"] # 全てのHTTPメソッドを許可
    allow_headers = ["content-type", "authorization", "x-amz-date", "x-amz-security-token"]
    max_age       = 300
  }
}

output "lambda_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.rust_lambda.arn
}

output "lambda_function_url" {
  description = "Lambda Function URL (AWS_IAM認証必須！)"
  value       = aws_lambda_function_url.rust_lambda_url.function_url
}

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