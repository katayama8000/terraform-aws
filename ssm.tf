
# Systems Manager Parameter Store for secrets

# Supabase URL (Not a secret, but good to manage here)
resource "aws_ssm_parameter" "supabase_url" {
  name  = "/expo-push-api/supabase-url"
  type  = "String"
  value = var.supabase_url
}

# Supabase Key (Secret)
resource "aws_ssm_parameter" "supabase_key" {
  name  = "/expo-push-api/supabase-key"
  type  = "SecureString"
  value = var.supabase_key
}

# Expo Access Token (Secret)
resource "aws_ssm_parameter" "expo_access_token" {
  name  = "/expo-push-api/expo-access-token"
  type  = "SecureString"
  value = var.expo_access_token
}
