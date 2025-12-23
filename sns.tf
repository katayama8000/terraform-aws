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
