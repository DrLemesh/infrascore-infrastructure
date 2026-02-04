output "backend_repo_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "frontend_repository_url" {
  value = aws_ecr_repository.frontend.repository_url
}

output "db_repository_url" {
  value = aws_ecr_repository.db.repository_url
}

output "pgadmin_repository_url" {
  value = aws_ecr_repository.pgadmin.repository_url
}
