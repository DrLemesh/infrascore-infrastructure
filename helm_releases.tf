# Deploy Helm charts automatically via Terraform
# This replaces the manual application module with automated Helm deployment

resource "helm_release" "infrascore" {
  name      = "infrascore"
  chart     = "../InfraScore/helm"
  namespace = "prod"

  # Use production values (includes all secrets and configuration)
  values = [
    file("../InfraScore/environments/prod/values.yaml")
  ]

  # Ensure EKS cluster is ready before deploying
  depends_on = [
    module.eks,
    module.helm_addons,
    aws_iam_role.s3_backup_role
  ]
}
