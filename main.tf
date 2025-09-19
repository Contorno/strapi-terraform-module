# Namespace
resource "kubernetes_namespace" "strapi" {
  metadata {
    name = var.namespace_name
  }
}

# PostgreSQL Secret
resource "kubernetes_secret" "postgres" {
  metadata {
    name      = "${var.name}-postgres"
    namespace = kubernetes_namespace.strapi.metadata[0].name
  }

  data = {
    postgres-password = var.postgres_password
  }

  type = "Opaque"
}

# Strapi Secrets
resource "kubernetes_secret" "strapi" {
  metadata {
    name      = "${var.name}-secrets"
    namespace = kubernetes_namespace.strapi.metadata[0].name
  }

  data = {
    ADMIN_JWT_SECRET  = var.strapi_admin_jwt_secret
    API_TOKEN_SALT    = var.strapi_api_token_salt
    APP_KEYS          = var.strapi_app_keys
    DATABASE_PASSWORD = var.postgres_password
  }

  type = "Opaque"
}

# PostgreSQL Helm Release
resource "helm_release" "postgresql" {
  name       = "${var.name}-postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "16.7.27"
  namespace  = kubernetes_namespace.strapi.metadata[0].name

  values = [
    yamlencode({
      auth = {
        postgresPassword = var.postgres_password
        database         = "strapi"
      }
      primary = {
        persistence = {
          enabled      = true
          storageClass = var.storage_class_name
          size         = var.postgres_storage_size
        }
      }
      metrics = {
        enabled = false
      }
    })
  ]

  depends_on = [kubernetes_secret.postgres]
}

# Strapi Uploads PVC
resource "kubernetes_persistent_volume_claim" "strapi_uploads" {
  metadata {
    name      = "${var.name}-uploads"
    namespace = kubernetes_namespace.strapi.metadata[0].name
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.storage_class_name

    resources {
      requests = {
        storage = var.strapi_uploads_storage_size
      }
    }
  }
}

# Strapi Deployment
resource "kubernetes_deployment" "strapi" {
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.strapi.metadata[0].name
    labels = {
      app = var.name
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.name
      }
    }

    template {
      metadata {
        labels = {
          app = var.name
        }
      }

      spec {
        container {
          name  = "strapi"
          image = "strapi/strapi:${var.strapi_version}"

          port {
            container_port = 1337
            protocol       = "TCP"
          }

          env {
            name = "NODE_ENV"
            value = "production"
          }

          env {
            name  = "DATABASE_CLIENT"
            value = "postgres"
          }

          env {
            name  = "DATABASE_HOST"
            value = "${var.name}-postgresql"
          }

          env {
            name  = "DATABASE_PORT"
            value = "5432"
          }

          env {
            name  = "DATABASE_NAME"
            value = "strapi"
          }

          env {
            name  = "DATABASE_USERNAME"
            value = "postgres"
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.strapi.metadata[0].name
            }
          }

          volume_mount {
            name       = "uploads"
            mount_path = "/opt/app/public/uploads"
          }

          resources {
            requests = {
              memory = "512Mi"
              cpu    = "250m"
            }
            limits = {
              memory = "1Gi"
              cpu    = "500m"
            }
          }

          liveness_probe {
            http_get {
              path = "/_health"
              port = 1337
            }
            initial_delay_seconds = 60
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 6
          }

          readiness_probe {
            http_get {
              path = "/_health"
              port = 1337
            }
            initial_delay_seconds = 30
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 3
          }
        }

        volume {
          name = "uploads"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.strapi_uploads.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [helm_release.postgresql]
}

# Strapi Service
resource "kubernetes_service" "strapi" {
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.strapi.metadata[0].name
    labels = {
      app = var.name
    }
  }

  spec {
    selector = {
      app = var.name
    }

    port {
      name        = "http"
      port        = 1337
      target_port = 1337
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}
