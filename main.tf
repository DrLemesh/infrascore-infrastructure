# 1. הקמת הרשת (Networking)
module "networking" {
  source       = "./modules/networking"
  project_name = var.project_name
}

# 2. הגדרת הרשאות (IAM)
module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
}

# 3. ECR repositories are managed outside Terraform (static)
# This speeds up terraform destroy and keeps images persistent

# 4. הקמת הקלאסטר (EKS) - שים לב להזרקת הנתונים מהמודולים הקודמים
module "eks" {
  source           = "./modules/eks"
  project_name     = var.project_name
  vpc_id           = module.networking.vpc_id
  subnet_ids       = module.networking.public_subnet_ids
  cluster_role_arn = module.iam.eks_cluster_role_arn
  node_role_arn    = module.iam.eks_nodes_role_arn
  ci_user_arn      = var.ci_user_arn
}

module "helm_addons" {
  source       = "./modules/helm-addons"
  project_name = var.project_name
  cluster_name = module.eks.cluster_name

  depends_on = [module.eks]
}

# Application deployment now handled by helm_releases.tf
# This ensures S3 backup/restore and CronJob are included
# module "application" {
#   source       = "./modules/application"
#   project_name = var.project_name
#   # Static ECR URLs (repos managed outside Terraform)
#   backend_image  = "941464113257.dkr.ecr.us-east-1.amazonaws.com/infrascore-backend"
#   frontend_image = "941464113257.dkr.ecr.us-east-1.amazonaws.com/infrascore-frontend"
#   db_image       = "941464113257.dkr.ecr.us-east-1.amazonaws.com/infrascore-db"
#   pgadmin_image  = "941464113257.dkr.ecr.us-east-1.amazonaws.com/infrascore-pgadmin"
#
#   db_password      = var.db_password
#   pgadmin_password = var.pgadmin_password
#
#   depends_on = [module.eks, module.helm_addons]
# }
