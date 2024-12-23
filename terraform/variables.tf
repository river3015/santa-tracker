variable "github_repository" {
  description = "GitHubリポジトリのURL"
  type        = string
}

variable "github_access_token" {
  description = "GitHubアクセストークン"
  type        = string
  sensitive   = true  # 機密情報として扱う
}
