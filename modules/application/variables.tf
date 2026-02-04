variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "environment" {
  description = "Environment (dev, prod)"
  type        = string
  default     = "dev"
}

variable "backend_image" {
  description = "ECR URL for backend image"
  type        = string
}

variable "frontend_image" {
  description = "ECR URL for frontend image"
  type        = string
}

variable "db_image" {
  description = "ECR URL for db image"
  type        = string
}

variable "pgadmin_image" {
  description = "ECR URL for pgadmin image"
  type        = string
}
