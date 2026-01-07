
# EventBridge Rule to trigger the API Gateway every 25th of the month
resource "aws_cloudwatch_event_rule" "every_25th_day_rule" {
  name                = "every-25th-day-rule"
  description         = "Fires every 25th day of the month"
  schedule_expression = "cron(0 0 25 * ? *)" # 00:00 UTC on the 25th of every month
}

# IAM Role for EventBridge to invoke the API Gateway
resource "aws_iam_role" "eventbridge_to_apigateway_role" {
  name = "EventBridgeToApiGatewayRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

# Connection to store API Key for authentication
resource "aws_cloudwatch_event_connection" "api_key_connection" {
  name               = "api-key-connection-for-expo-push"
  authorization_type = "API_KEY"

  auth_parameters {
    api_key {
      key   = "x-api-key"
      value = random_password.expo_push_notification_api_key.result
    }
  }
}

# API Destination pointing to the API Gateway
resource "aws_cloudwatch_event_api_destination" "api_destination" {
  name                          = "expo-push-api-destination"
  connection_arn                = aws_cloudwatch_event_connection.api_key_connection.arn
  invocation_endpoint           = "${aws_apigatewayv2_stage.expo_push_notification_api_default.invoke_url}/"
  http_method                   = "POST"
  invocation_rate_limit_per_second = 1
}

# IAM Policy to allow invoking the API Destination
resource "aws_iam_policy" "invoke_api_destination_policy" {
  name        = "InvokeApiDestinationPolicy"
  description = "Policy to invoke the API Destination for Expo Push"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "events:InvokeApiDestination",
        Effect   = "Allow",
        Resource = aws_cloudwatch_event_api_destination.api_destination.arn
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "eventbridge_to_apidestination_attachment" {
  role       = aws_iam_role.eventbridge_to_apigateway_role.name
  policy_arn = aws_iam_policy.invoke_api_destination_policy.arn
}

# EventBridge Target to link the rule to the API Destination
resource "aws_cloudwatch_event_target" "api_destination_target" {
  rule     = aws_cloudwatch_event_rule.every_25th_day_rule.name
  arn      = aws_cloudwatch_event_api_destination.api_destination.arn
  role_arn = aws_iam_role.eventbridge_to_apigateway_role.arn
}
