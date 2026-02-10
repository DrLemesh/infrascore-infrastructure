variable "project_name" {}
variable "cluster_role_arn" {}
variable "node_role_arn" {}
variable "subnet_ids" { type = list(string) }
variable "vpc_id" {}

variable "ci_user_arn" {
  description = "ARN of the IAM user for CI/CD"
  type        = string
}
