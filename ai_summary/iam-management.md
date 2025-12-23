# IAM管理の概要

## プロジェクト構成

このTerraformプロジェクトは、AWS上のリソースを管理するために以下のファイルに分割されています：

- **provider.tf** - AWSプロバイダーの設定とリージョン変数
- **iam.tf** - IAMロール、ポリシー、アタッチメントの管理
- **lambda.tf** - Lambda関数の定義
- **sns.tf** - SNSトピックの管理
- **main.tf** - メインファイル（リソースは各専用ファイルに分離）

## 管理中のIAMリソース

現在、以下のIAMリソースがTerraformで管理されています：

### 1. IAMロール: `cargo-lambda-role-b0ef0eaa-1171-49f3-a430-9cef163e875a`

**用途**: Lambda関数の実行用ロール

**信頼ポリシー**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

**タグ**:
- Name: Cargo Lambda Role
- Environment: Dev
- ManagedBy: Terraform

**作成日**: 2025-12-21T06:57:26+00:00
**最終使用日**: 2025-12-21T08:34:00+00:00

### 2. ポリシーアタッチメント: AWSLambdaBasicExecutionRole

**アタッチされているマネージドポリシー**:
- ARN: `arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole`

**提供される権限**:
- CloudWatch Logsへのログ出力権限
- ログストリームの作成権限
- ロググループの作成権限

## AWS上の他のIAMロール（未管理）

以下のIAMロールがAWS上に存在していますが、現在はTerraformで管理していません：

1. **cargo-lambda-role-ff63354a-65d4-40c6-8618-30ed77f88ed8**
   - 作成日: 2025-12-21T02:57:16+00:00
   - 別のLambda関数用と思われる

2. **myFunctionRust-role-d37chbba**
   - 作成日: 2025-12-13T14:45:58+00:00
   - サービスロール

3. **AWSServiceRoleForResourceExplorer**
   - AWS管理のサービスロール
   - 作成日: 2025-12-21T02:13:01+00:00

4. **AWSServiceRoleForSupport**
   - AWS管理のサービスロール
   - 作成日: 2022-02-08T02:41:11+00:00

5. **AWSServiceRoleForTrustedAdvisor**
   - AWS管理のサービスロール
   - 作成日: 2022-02-08T02:41:11+00:00

## 既存リソースのインポート方法

AWS上の既存リソースをTerraformで管理する場合の手順：

### 1. 環境変数を設定
```bash
export AWS_ACCESS_KEY_ID=your-key
export AWS_SECRET_ACCESS_KEY=your-secret
export AWS_DEFAULT_REGION=ap-northeast-1
```

### 2. IAMロールの詳細を確認
```bash
aws iam get-role --role-name role-name
aws iam list-attached-role-policies --role-name role-name
aws iam list-role-policies --role-name role-name
```

### 3. Terraformコードを作成
iam.tfに対応するリソース定義を追加

### 4. リソースをインポート
```bash
# IAMロールをインポート
terraform import aws_iam_role.role_name actual-role-name

# IAMポリシーアタッチメントをインポート
terraform import aws_iam_role_policy_attachment.attachment_name role-name/policy-arn
```

### 5. 差分を確認
```bash
terraform plan
```

差分がない場合、正常にインポートされています。

## デプロイ済みリソース

- **SNS トピック**: `terraform-test-topic`
- **Lambda 関数**: `my-rust-lambda` (Rust runtime on AL2023、ARM64)
- **IAMロール**: Lambda実行用ロール（上記）

## ベストプラクティス

1. **IAMロールの命名**: UUIDを含めて一意性を確保
2. **タグ付け**: Environment、ManagedBy、Nameタグを必ず付ける
3. **最小権限の原則**: 必要最小限の権限のみを付与
4. **マネージドポリシーの活用**: AWS提供のマネージドポリシーを優先的に使用
5. **状態管理**: terraform planで定期的に差分を確認

## インポート完了状況

- ✅ IAMロール: `cargo-lambda-role-b0ef0eaa-1171-49f3-a430-9cef163e875a`
- ✅ ポリシーアタッチメント: `AWSLambdaBasicExecutionRole`
- ✅ terraform plan で差分なし確認済み

最終確認日: 2025-12-23
