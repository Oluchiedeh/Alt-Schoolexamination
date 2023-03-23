resource "kubernetes_deployment" "app1-vote-back" {
  metadata {
    name = "app1-vote-back-deploy"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "app1-vote-back-deploy"
      }
    }

    template {
      metadata {
        labels = {
          app = "app1-vote-back-deploy"
        }
      }

      spec {
        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }

        container {
          name = "app1-vote-back-deploy"
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

resource "kubernetes_service" "app1-vote-back-deploy" {
  metadata {
    name = "app1-vote-back-deploy"
  }

  spec {
    port {
      port = 6379
    }

    selector = {
      app = "app1-vote-back-deploy"
    }
  }
}

resource "kubernetes_deployment" "app1-vote-front-deploy" {
  metadata {
    name = "app1-vote-front-deploy"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "app1-vote-front-deploy"
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
          app = "app1-vote-front-deploy"
        }
      }

      spec {
        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }

        container {
          name = "app1-vote-front-deploy"
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
            value = "app1-vote-back"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app1-vote-front-deploy" {
  metadata {
    name = "app1-vote-front-deploy"
  }

  spec {
    port {
      port = 80
    }

    selector = {
      app = "app1-vote-front"
    }
  }
}
