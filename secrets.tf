resource "kubernetes_namespace" "prod" {
  metadata {
    name = "prod"
  }
}

resource "kubernetes_secret" "gemini_secret" {
  metadata {
    name      = "gemini-secret"
    namespace = kubernetes_namespace.prod.metadata[0].name
  }

  data = {
    api-key = var.gemini_api_key
  }

  type = "Opaque"

  # Ensure namespace exists first (created by ArgoCD usually, but let's be safe or rely on depends_on)
  # Actually, the 'prod' namespace is created by ArgoCD sync.
  # If we apply this BEFORE ArgoCD runs, it will fail because namespace 'prod' doesn't exist.
  # So we should put this inside the helm-addons module or make it depend on something that creates the namespace.
  # OR, create the namespace via terraform?
}
