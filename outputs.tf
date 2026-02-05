# --- ECR Outputs ---
output "backend_repository_url" {
  description = "The URL of the backend ECR repository"
  value       = module.ecr.backend_repo_url
}

output "frontend_repository_url" {
  description = "The URL of the frontend ECR repository"
  value       = module.ecr.frontend_repository_url
}

output "db_repository_url" {
  description = "The URL of the DB ECR repository"
  value       = module.ecr.db_repository_url
}

output "pgadmin_repository_url" {
  description = "The URL of the PgAdmin ECR repository"
  value       = module.ecr.pgadmin_repository_url
}

# --- EKS & Connectivity ---
output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "update_kubeconfig_command" {
  description = "Run this command to connect your local kubectl to the cluster"
  value       = "aws eks update-kubeconfig --region us-east-1 --name ${module.eks.cluster_name}"
}

# --- ArgoCD ---
output "argocd_url" {
  description = "ArgoCD UI Public URL"
  value       = module.helm_addons.argocd_url
}

output "grafana_url" {
  description = "Grafana Dashboard Public URL"
  value       = module.helm_addons.grafana_url
}

# --- Application ---
output "frontend_url" {
  description = "The public URL for the Frontend Application"
  value       = module.application.frontend_service_hostname
}

output "pgadmin_url" {
  description = "The public URL for the PgAdmin Dashboard"
  value       = module.application.pgadmin_service_hostname
}

# --- S3 Backup ---
output "s3_backup_bucket_name" {
  description = "The name of the S3 bucket for database backups (manually created)"
  value       = data.aws_s3_bucket.backups.id
}

output "s3_backup_bucket_arn" {
  description = "The ARN of the S3 bucket for database backups (manually created)"
  value       = data.aws_s3_bucket.backups.arn
}
