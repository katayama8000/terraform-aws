# Lambda IAM Role
resource "aws_iam_role" "lambda_role" {
  name = "cargo-lambda-role-b0ef0eaa-1171-49f3-a430-9cef163e875a"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "Cargo Lambda Role"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# AWSマネージドポリシーをアタッチ（CloudWatch Logs用）
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

output "lambda_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = aws_iam_role.lambda_role.arn
}

# IAM Role for Expo Push Notification API
resource "aws_iam_role" "expo_push_notification_api_role" {
  name = "expo-push-notification-api-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "Expo Push Notification API Role"
    Environment = "Prd"
    ManagedBy   = "Terraform"
  }
}

# Attach AWS managed policy for CloudWatch Logs
resource "aws_iam_role_policy_attachment" "expo_push_notification_api_lambda_basic_execution" {
  role       = aws_iam_role.expo_push_notification_api_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

output "expo_push_notification_api_role_arn" {
  description = "ARN of the Expo Push Notification API Lambda IAM role"
  value       = aws_iam_role.expo_push_notification_api_role.arn
}

# Data sources to get current region and account ID
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# IAM Policy to allow reading secrets from SSM Parameter Store
resource "aws_iam_policy" "ssm_read_policy" {
  name        = "ssm-read-expo-push-api-secrets"
  description = "Allows reading specific SSM parameters for Expo Push API"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "ssm:GetParametersByPath",
        Resource = "arn:aws:ssm:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:parameter/expo-push-api/*"
      },
      {
        Effect   = "Allow",
        Action   = "kms:Decrypt",
        # This allows decrypting with any key in the account. For better security, 
        # you could restrict this to the specific KMS key used by SSM.
        Resource = "*"
      }
    ]
  })
}

# Attach the SSM read policy to the Lambda role
resource "aws_iam_role_policy_attachment" "ssm_read_attachment" {
  role       = aws_iam_role.expo_push_notification_api_role.name
  policy_arn = aws_iam_policy.ssm_read_policy.arn
}
