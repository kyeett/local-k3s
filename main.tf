terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

locals {
  app_name = "my-app"
  service_name = "service-name"
}

provider "kubernetes" {
  config_path = "./k3s.yaml"
}

provider "helm" {
  kubernetes {
    config_path = "./k3s.yaml"
  }
}

resource "kubernetes_deployment" "my-app" {
  metadata {
    name = local.app_name
  }
  spec {
    replicas = 3
    selector {
      match_labels = {
        app = local.app_name
      }
    }
    template {
      metadata {
        labels = {
          app = local.app_name
        }
      }
      spec {
        container {
          image = "tigrlily/mongo-app:v1"
          name = "gcr"
          port {
            container_port = 80
          }
          env {
            name = "PORT"
            value = "80"
          }
          env {
            name = "MONGO_URI"
            value = "mongodb://10.42.0.1:27017"
          }
          liveness_probe {
            http_get {
              path = "/healthcheck"
              port = 80 // Can this be parameterized?
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_pod" "my-sea-shell" {
  metadata {
    name = "sea-shell"
  }
  spec {
    container {
      image = "praqma/network-multitool"
      name = "shell"
      command = ["sleep", "10000"]
    }
  }
}

resource "kubernetes_service" "example" {
  metadata {
    name = local.service_name
  }
  spec {
    selector = {
      app = kubernetes_deployment.my-app.spec.0.template.0.metadata.0.labels.app
    }
    session_affinity = "ClientIP"

    port {
      port = 8081
      target_port = 80
    }
  }
}

resource "kubernetes_ingress" "example_ingress" {
  metadata {
    name = "example-ingress"
  }

  spec {
    backend {
      service_name = local.service_name
      service_port = kubernetes_service.example.spec.0.port.0.port
    }

    rule {
      http {
        path {
          backend {
            service_name = local.service_name
            service_port = 80
          }

          path = "/app1/*"
        }

        path {
          backend {
            service_name = local.service_name
            service_port = 8080
          }

          path = "/app2/*"
        }
      }
    }
  }
}

output "result" {
  value = {
    "local": local.app_name,
  }
}