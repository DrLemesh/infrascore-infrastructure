variable "project_name" {
  default = "infrascore"
}

variable "db_password" {
  description = "Password for the PostgreSQL database"
  type        = string
  sensitive   = true
}

variable "pgadmin_password" {
  description = "Password for PgAdmin default user"
  type        = string
  sensitive   = true
}
