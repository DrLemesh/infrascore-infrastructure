# Deploy ArgoCD Application manifest to configure GitOps
# ArgoCD will watch the Git repo and auto-deploy Helm charts

# Note: Using null_resource with kubectl instead of kubernetes_manifest
# because kubernetes_manifest requires API server access during plan phase
resource "null_resource" "argocd_application" {
  # This will re-run if you manually taint the resource
  triggers = {
    cluster_name = module.eks.cluster_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Update kubeconfig to point to the new cluster
      aws eks update-kubeconfig --region us-east-1 --name infrascore-cluster
      
      # Wait for ArgoCD to be ready
      kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd || true
      
      # Apply the ArgoCD Application manifest
      # Using quoted 'EOF' to prevent shell interpolation of $values, but Terraform still interpolates vars
      cat <<'EOF' | kubectl apply -f - --validate=false
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: infrascore-prod
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  sources:
    - repoURL: https://github.com/DrLemesh/InfraScore
      targetRevision: main
      path: ./helm
      helm:
        valueFiles:
          - $values/environments/prod/values.yaml
        parameters:
          - name: "frontend-chart.env.API_URL"
            value: "http://infrascore-prod-backend-chart"
          - name: "database-chart.env.POSTGRES_PASSWORD"
            value: "${var.db_password}"
          - name: "pgadmin-chart.secrets.pgadmin_password"
            value: "${var.pgadmin_password}"
          - name: "pgadmin-chart.secrets.pgadmin_email"
            value: "${var.pgadmin_email}"
          - name: "database-chart.serviceAccount.roleArn"
            value: "${aws_iam_role.s3_backup_role.arn}"
    - repoURL: https://github.com/DrLemesh/infrascore-gitops
      targetRevision: main
      ref: values
  destination:
    server: https://kubernetes.default.svc
    namespace: prod
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - Validate=true
      - ServerSideApply=false
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
EOF
    EOT
  }

  # Clean up on destroy
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete application infrascore-prod -n argocd --ignore-not-found=true"
  }

  depends_on = [
    module.helm_addons # Ensure ArgoCD is installed first
  ]
}
