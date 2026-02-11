# התקנת ArgoCD (כבר קיים אצלך)
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.7.16" # Pinning version for stability
  namespace        = "argocd"
  create_namespace = true
  wait             = true
  timeout          = 600

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }
}

# ניהול StorageClass ברירת מחדל: ביטול gp2 כדי ש-gp3 יתפוס
resource "null_resource" "disable_gp2_default" {
  provisioner "local-exec" {
    command = "kubectl patch storageclass gp2 -p '{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"false\"}}}' || true"

    # שימוש במשתני סביבה כדי להבטיח שהפקודה רצה מול הקלאסטר הנכון (אם מוגדר ב-kubeconfig)
    # הערה: זה מניח שהמשתמש הריץ aws eks update-kubeconfig. 
    # אם זה רץ ב-CI/CD, צריך לוודא שיש גישה.
  }

  depends_on = [var.cluster_name] # תלות עקיפה בקלאסטר
}

# הגדרת StorageClass עבור Persistent Volumes (EBS)
# זה קריטי עבור Prometheus ו-Grafana כדי לשמור מידע
resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"

  parameters = {
    type   = "gp3"
    fsType = "ext4"
  }

  depends_on = [null_resource.disable_gp2_default]
}

# התקנת Prometheus & Grafana Stack
resource "helm_release" "prometheus_stack" {
  name             = "prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "68.4.4" # Pinning version for stability
  namespace        = "monitoring"
  create_namespace = true
  wait             = true
  timeout          = 600

  # הגדרת Grafana להיות נגישה דרך LoadBalancer כדי שתוכל להיכנס לממשק
  set {
    name  = "grafana.service.type"
    value = "LoadBalancer"
  }

  # הגדרת StorageClass ל-Prometheus באופן מפורש
  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
    value = "gp3"
  }

  depends_on = [
    kubernetes_storage_class.gp3
  ]
}
