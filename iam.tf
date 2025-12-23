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
