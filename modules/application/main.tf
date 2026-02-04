resource "kubernetes_namespace" "app" {
  metadata {
    name = "infrascore"
  }
}

resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "db-credentials"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    POSTGRES_USER     = "postgres"
    POSTGRES_PASSWORD = "password123"
    POSTGRES_DB       = "infrascore"
  }
}

# --- Database ---
resource "kubernetes_deployment" "db" {
  metadata {
    name      = "infrascore-db"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app = "infrascore-db"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "infrascore-db"
      }
    }
    template {
      metadata {
        labels = {
          app = "infrascore-db"
        }
      }
      spec {
        container {
          image = "postgres:15" # Using official image since private one is missing
          name  = "db"
          port {
            container_port = 5432
          }
          env_from {
            secret_ref {
              name = kubernetes_secret.db_credentials.metadata[0].name
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "db" {
  metadata {
    name      = "infrascore-db"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  spec {
    selector = {
      app = "infrascore-db"
    }
    port {
      port        = 5432
      target_port = 5432
    }
  }
}

# --- PgAdmin ---
resource "kubernetes_deployment" "pgadmin" {
  metadata {
    name      = "infrascore-pgadmin"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app = "infrascore-pgadmin"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "infrascore-pgadmin"
      }
    }
    template {
      metadata {
        labels = {
          app = "infrascore-pgadmin"
        }
      }
      spec {
        container {
          image = "${var.pgadmin_image}:latest"
          name  = "pgadmin"
          port {
            container_port = 80
          }
          env {
            name  = "PGADMIN_DEFAULT_EMAIL"
            value = "admin@infrascore.com"
          }
          env {
            name  = "PGADMIN_DEFAULT_PASSWORD"
            value = "admin123"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "pgadmin" {
  metadata {
    name      = "infrascore-pgadmin"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  spec {
    type = "LoadBalancer"
    selector = {
      app = "infrascore-pgadmin"
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}

# --- Backend ---
resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "infrascore-backend"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app = "infrascore-backend"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "infrascore-backend"
      }
    }
    template {
      metadata {
        labels = {
          app = "infrascore-backend"
        }
      }
      spec {
        container {
          image = "${var.backend_image}:latest"
          name  = "backend"
          port {
            container_port = 5000
          }
          env {
            name  = "DB_HOST"
            value = "infrascore-db"
          }
          env {
            name  = "DB_PORT"
            value = "5432"
          }
          env_from {
            secret_ref {
              name = kubernetes_secret.db_credentials.metadata[0].name
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "backend" {
  metadata {
    name      = "infrascore-backend"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  spec {
    selector = {
      app = "infrascore-backend"
    }
    port {
      port        = 5000
      target_port = 5000
    }
  }
}

# --- Frontend ---
resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = "infrascore-frontend"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app = "infrascore-frontend"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "infrascore-frontend"
      }
    }
    template {
      metadata {
        labels = {
          app = "infrascore-frontend"
        }
      }
      spec {
        container {
          image = "${var.frontend_image}:latest"
          name  = "frontend"
          port {
            container_port = 80
          }
          env {
            name  = "REACT_APP_BACKEND_URL"
            value = "http://infrascore-backend:5000"
          }
          env {
            name  = "API_URL"
            value = "http://infrascore-backend:5000"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    name      = "infrascore-frontend"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  spec {
    type = "LoadBalancer"
    selector = {
      app = "infrascore-frontend"
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}
