variable "github_repository" {
  description = "GitHubリポジトリのURL"
  type        = string
}

variable "github_access_token" {
  description = "GitHubアクセストークン"
  type        = string
  sensitive   = true  # 機密情報として扱う
}

variable "domain_name" {
  description = "Domain name for the Santa Tracker application"
  type        = string
}