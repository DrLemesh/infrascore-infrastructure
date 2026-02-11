# --- ECR Outputs (now static, managed outside Terraform) ---
# backend: 941464113257.dkr.ecr.us-east-1.amazonaws.com/infrascore-backend
# frontend: 941464113257.dkr.ecr.us-east-1.amazonaws.com/infrascore-frontend
# db: 941464113257.dkr.ecr.us-east-1.amazonaws.com/infrascore-db
# pgadmin: 941464113257.dkr.ecr.us-east-1.amazonaws.com/infrascore-pgadmin

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
  description = "The public URL for the ArgoCD Server"
  value       = module.helm_addons.argocd_url
}

output "grafana_url" {
  description = "The public URL for Grafana"
  value       = module.helm_addons.grafana_url
}

# --- Application URLs (commented out - using Helm now) ---
# output "frontend_url" {
#   description = "The public URL for the Frontend Application"
#   value       = module.application.frontend_service_hostname
# }
#
# output "pgadmin_url" {
#   description = "The public URL for the PgAdmin Dashboard"
#   value       = module.application.pgadmin_service_hostname
# }

# --- S3 Backup ---
output "s3_backup_bucket_name" {
  description = "The name of the S3 bucket for database backups (manually created)"
  value       = data.aws_s3_bucket.backups.id
}

output "s3_backup_bucket_arn" {
  description = "The ARN of the S3 bucket for database backups (manually created)"
  value       = data.aws_s3_bucket.backups.arn
}
