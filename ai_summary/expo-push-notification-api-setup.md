# Expo Push Notification API構築手順

## 1. 概要

Expo Push Notification APIをAWS Lambda + API Gatewayで構築するための手順書です。
TerraformでAWSリソースを管理し、Lambda関数はRustで実装し、`cargo-lambda` を使ってデプロイします。

## 2. TerraformによるAWSリソースの作成

既存のTerraform設定ファイル (`lambda.tf`, `api-gateway.tf`, `iam.tf`) に、以下のリソース定義を追記します。

### `iam.tf` への追記

新しいLambda関数用のIAMロールを作成します。

```hcl
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
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# Attach AWS managed policy for CloudWatch Logs
resource "aws_iam_role_policy_attachment" "expo_push_notification_api_lambda_basic_execution" {
  role       = aws_iam_role.expo_push_notification_api_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
```

### `lambda.tf` への追記

新しいLambda関数を定義します。`filename` と `source_code_hash` は `cargo-lambda` で管理するため、`ignore_changes` を設定します。

```hcl
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

  environment = {
    variables = {
      API_KEY = random_password.expo_push_notification_api_key.result
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
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }

  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash,
    ]
  }
}
```

### `api-gateway.tf` への追記

API Gatewayのエンドポイントを作成し、Lambda関数と連携させます。

```hcl
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
```

## 3. `terraform apply` の実行

上記のリソースを追記した後、`terraform apply` を実行してAWSリソースを作成します。

```bash
terraform apply
```

## 4. Rust (`cargo-lambda`) プロジェクトの設定

Lambda関数を実装するRustプロジェクトを別途作成します。

### プロジェクトの作成

```bash
cargo new expo-push-notification-api
cd expo-push-notification-api
```

### `Cargo.toml` の編集

以下の依存関係を `Cargo.toml` に追加します。

```toml
[package]
name = "expo-push-notification-api"
version = "0.1.0"
edition = "2021"

[dependencies]
lambda_runtime = "0.10"
tokio = { version = "1", features = ["macros"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
reqwest = { version = "0.12", features = ["json"] }
http = "0.2"
```

### `src/main.rs` の実装例

API Gatewayからのリクエストを処理し、ExpoのPush APIにリクエストを送信する基本的なコード例です。
APIキーの検証も行っています。

```rust
use lambda_runtime::{service_fn, Error, LambdaEvent};
use serde::{Deserialize, Serialize};
use http::header::{HeaderMap, HeaderValue};
use std::env;

#[derive(Deserialize, Debug)]
struct ApiGatewayRequest {
    headers: HeaderMap<HeaderValue>,
    body: String,
}

#[derive(Deserialize, Debug)]
struct PushNotificationRequest {
    to: String,
    title: String,
    body: String,
}

#[derive(Serialize)]
struct ApiGatewayResponse {
    #[serde(rename = "isBase64Encoded")]
    is_base64_encoded: bool,
    #[serde(rename = "statusCode")]
    status_code: u16,
    headers: HeaderMap<HeaderValue>,
    body: String,
}

async fn handler(event: LambdaEvent<ApiGatewayRequest>) -> Result<ApiGatewayResponse, Error> {
    let api_key = env::var("API_KEY").expect("API_KEY must be set");

    let request_api_key = event.payload.headers
        .get("x-api-key")
        .and_then(|v| v.to_str().ok())
        .unwrap_or("");

    if api_key != request_api_key {
        return Ok(ApiGatewayResponse {
            is_base64_encoded: false,
            status_code: 401,
            headers: HeaderMap::new(),
            body: "Unauthorized".to_string(),
        });
    }

    let push_request: PushNotificationRequest = serde_json::from_str(&event.payload.body)?;

    // ここにExpo Push APIへリクエストを送信する処理を実装します。
    // (例: reqwest::Clientを使って https://exp.host/--/api/v2/push/send へPOSTリクエスト)
    println!("Sending push notification to: {}", push_request.to);


    let response_body = format!("Push notification request for '{}' processed.", push_request.to);

    Ok(ApiGatewayResponse {
        is_base64_encoded: false,
        status_code: 200,
        headers: HeaderMap::new(),
        body: response_body,
    })
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    lambda_runtime::run(service_fn(handler)).await
}
```

## 5. `cargo-lambda` によるデプロイ

`cargo-lambda` を使ってLambda関数をデプロイします。`terraform apply` で作成したIAMロールのARNを指定してください。

```bash
# ビルド
cargo lambda build --release --arm64

# デプロイ
cargo lambda deploy \
  --function-name expo-push-notification-api \
  --role $(terraform output -raw expo_push_notification_api_role_arn) \
  --region <デプロイ先のリージョン>
```

**注意**: 上記のデプロイコマンドでは `terraform output` を利用してIAMロールのARNを自動で取得しています。`expo_push_notification_api_role_arn` というoutputを `iam.tf` に追加する必要があります。

`iam.tf` に以下を追記してください。

```hcl
output "expo_push_notification_api_role_arn" {
  description = "ARN of the Expo Push Notification API Lambda IAM role"
  value       = aws_iam_role.expo_push_notification_api_role.arn
}
```

