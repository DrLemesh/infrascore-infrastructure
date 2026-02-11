variable "project_name" {
  default = "infrascore"
}

variable "ci_user_arn" {
  description = "IAM User ARN for CI/CD (GitHub Actions)"
  default     = "arn:aws:iam::941464113257:user/gh-actions-user"
}

variable "db_password" {
  description = "Password for the database"
  type        = string
  default     = "ChangeMe123!"
}

variable "pgadmin_password" {
  description = "Password for pgAdmin"
  type        = string
  default     = "ChangeMe123!"
}

