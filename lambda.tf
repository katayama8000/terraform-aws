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
