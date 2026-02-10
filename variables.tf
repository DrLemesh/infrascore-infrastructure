variable "project_name" {
  default = "infrascore"
}

variable "ci_user_arn" {
  description = "IAM User ARN for CI/CD (GitHub Actions)"
  default     = "arn:aws:iam::941464113257:user/gh-actions-user"
}

