variable "supabase_url" {
  description = "The URL of the Supabase project."
  type        = string
  sensitive   = false # URL is not typically a secret, but can be if desired
}

variable "supabase_key" {
  description = "The service_role key for the Supabase project."
  type        = string
  sensitive   = true
}

variable "expo_access_token" {
  description = "The access token for the Expo Push Notification service."
  type        = string
  sensitive   = true
}
