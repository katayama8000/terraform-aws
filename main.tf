
provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

resource "aws_sns_topic" "test_topic" {
  name = "terraform-test-topic"

  tags = {
    Name        = "Terraform Test Topic"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

output "topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.test_topic.arn
}

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

output "lambda_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.rust_lambda.arn
}

output "lambda_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = aws_iam_role.lambda_role.arn
}
