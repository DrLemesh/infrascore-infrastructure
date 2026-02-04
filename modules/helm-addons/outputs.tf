data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = helm_release.argocd.namespace
  }
  depends_on = [helm_release.argocd]
}

output "argocd_url" {
  value = data.kubernetes_service.argocd_server.status.0.load_balancer.0.ingress.0.hostname
}

data "kubernetes_service" "grafana" {
  metadata {
    name      = "prometheus-stack-grafana"
    namespace = "monitoring"
  }
  depends_on = [helm_release.prometheus_stack]
}

output "grafana_url" {
  value = data.kubernetes_service.grafana.status.0.load_balancer.0.ingress.0.hostname
}
