
# Systems Manager Parameter Store for secrets

# Supabase URL (Not a secret, but good to manage here)
resource "aws_ssm_parameter" "supabase_url" {
  name  = "/expo-push-api/supabase-url"
  type  = "String"
  value = "YOUR_SUPABASE_URL" # TODO: Replace with your actual Supabase URL
}

# Supabase Key (Secret)
resource "aws_ssm_parameter" "supabase_key" {
  name  = "/expo-push-api/supabase-key"
  type  = "SecureString"
  value = "YOUR_SUPABASE_KEY" # TODO: Replace with your actual Supabase Key
}

# Expo Access Token (Secret)
resource "aws_ssm_parameter" "expo_access_token" {
  name  = "/expo-push-api/expo-access-token"
  type  = "SecureString"
  value = "YOUR_EXPO_ACCESS_TOKEN" # TODO: Replace with your actual Expo Access Token
}
