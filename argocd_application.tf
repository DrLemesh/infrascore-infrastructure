# Deploy ArgoCD Application manifest to configure GitOps
# ArgoCD will watch the Git repo and auto-deploy Helm charts

resource "kubernetes_manifest" "argocd_application" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "infrascore-prod"
      namespace = "argocd"
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    spec = {
      project = "default"

      sources = [
        # Source 1: Helm charts from InfraScore repo
        {
          repoURL        = "https://github.com/DrLemesh/InfraScore"
          targetRevision = "main"
          path           = "./helm"
          helm = {
            valueFiles = [
              "$values/environments/prod/values.yaml"
            ]
          }
        },
        # Source 2: Values from GitOps repo
        {
          repoURL        = "https://github.com/DrLemesh/infrascore-gitops"
          targetRevision = "main"
          ref            = "values"
        }
      ]

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "prod"
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true",
          "Validate=true",
          "ServerSideApply=false"
        ]
        retry = {
          limit = 5
          backoff = {
            duration    = "5s"
            factor      = 2
            maxDuration = "3m"
          }
        }
      }
    }
  }

  depends_on = [
    module.helm_addons # Ensure ArgoCD is installed first
  ]
}
