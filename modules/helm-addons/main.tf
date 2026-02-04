# התקנת ArgoCD (כבר קיים אצלך)
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }
}

# התקנת Prometheus & Grafana Stack
resource "helm_release" "prometheus_stack" {
  name             = "prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true

  # הגדרת Grafana להיות נגישה דרך LoadBalancer כדי שתוכל להיכנס לממשק
  set {
    name  = "grafana.service.type"
    value = "LoadBalancer"
  }
}