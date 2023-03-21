resource "kubernetes_deployment" "app-vote-back" {
  metadata {
    name = "app-vote-back-deploy"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "app-vote-back-deploy"
      }
    }

    template {
      metadata {
        labels = {
          app = "app-vote-back-deploy"
        }
      }

      spec {
        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }

        container {
          name = "app-vote-back-deploy"
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

resource "kubernetes_service" "app-vote-back-deploy" {
  metadata {
    name = "app-vote-back-deploy"
  }

  spec {
    port {
      port = 6379
    }

    selector = {
      app = "app-vote-back-deploy"
    }
  }
}

resource "kubernetes_deployment" "app-vote-front-deploy" {
  metadata {
    name = "app-vote-front-deploy"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "app-vote-front-deploy"
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
          app = "app-vote-front-deploy"
        }
      }

      spec {
        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }

        container {
          name = "app-vote-front-deploy"
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
            value = "app-vote-back"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app-vote-front-deploy" {
  metadata {
    name = "app-vote-front-deploy"
  }

  spec {
    port {
      port = 80
    }

    selector = {
      app = "app-vote-front"
    }
  }
}
