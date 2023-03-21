resource "kubernetes_deployment" "vote-back" {
  metadata {
    name = "vote-back-deploy"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "vote-back-deploy"
      }
    }

    template {
      metadata {
        labels = {
          app = "vote-back-deploy"
        }
      }

      spec {
        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }

        container {
          name = "vote-back-deploy"
          image = "mcr.microsoft.com/oss/bitnami/redis:6.0.8"

          env {
            name = "ALLOW_EMPTY_PASSWORD"
            value = "yes"
          }

          port {
            container_port = 6379
            name = "redis"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "vote-back-deploy" {
  metadata {
    name = "vote-back-deploy"
  }

  spec {
    port {
      port = 6379
    }

    selector = {
      app = "vote-back-deploy"
    }
  }
}

resource "kubernetes_deployment" "vote-front-deploy" {
  metadata {
    name = "vote-front-deploy"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "vote-front-deploy"
      }
    }

    strategy {
      rolling_update {
        max_surge = 1
        max_unavailable = 1
      }
    }

    min_ready_seconds = 5

    template {
      metadata {
        labels = {
          app = "vote-front-deploy"
        }
      }

      spec {
        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }

        container {
          name = "vote-front-deploy"
          image = "mcr.microsoft.com/azuredocs/azure-vote-front:v1"

          port {
            container_port = 80
          }

          resources {
            requests = {
              cpu = "250m"
            }

            limits = {
              cpu = "500m"
            }
          }

          env {
            name = "REDIS"
            value = "vote-back"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "vote-front-deploy" {
  metadata {
    name = "vote-front-deploy"
  }

  spec {
    port {
      port = 80
    }

    selector = {
      app = "vote-front"
    }
  }
}
