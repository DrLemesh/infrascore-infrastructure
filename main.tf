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

# 3. יצירת מחסני אימג'ים (ECR)
module "ecr" {
  source       = "./modules/ecr"
  project_name = var.project_name
}

# 4. הקמת הקלאסטר (EKS) - שים לב להזרקת הנתונים מהמודולים הקודמים
module "eks" {
  source           = "./modules/eks"
  project_name     = var.project_name
  vpc_id           = module.networking.vpc_id
  subnet_ids       = module.networking.public_subnet_ids
  cluster_role_arn = module.iam.eks_cluster_role_arn
  node_role_arn    = module.iam.eks_nodes_role_arn
}

module "helm_addons" {
  source       = "./modules/helm-addons"
  project_name = var.project_name
  cluster_name = module.eks.cluster_name

  depends_on = [module.eks]
}

module "application" {
  source         = "./modules/application"
  project_name   = var.project_name
  backend_image  = module.ecr.backend_repo_url
  frontend_image = module.ecr.frontend_repository_url
  db_image       = module.ecr.db_repository_url
  pgadmin_image  = module.ecr.pgadmin_repository_url

  depends_on = [module.eks, module.ecr, module.helm_addons]
}

