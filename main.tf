terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }

//    heroku = {
//      source = "heroku/heroku"
//      version = "3.2.0"
//    }
  }
}

locals {
  app_name = "MyBetterApp"
}

provider "kubernetes" {
  config_path = "./k3s.yaml"
}

provider "helm" {
  kubernetes {
    config_path = "./k3s.yaml"
  }
}

//
//provider "heroku" {
//  email = var.heroku_email
//  api_key = var.heroku_api_key
//}
//
//# Create a new Heroku app
//resource "heroku_app" "db-hoster" {
//  name = "k3s-postgres-hoster"
//  region = "eu"
//}
//
//
//# Create a database, and configure the app to use it
//resource "heroku_addon" "database" {
//  app = heroku_app.db-hoster.name
//  plan = "heroku-postgresql:hobby-dev"
//}
//
//resource "kubernetes_secret" "app_database_url" {
//  metadata {
//    name = "app-database-url"
//  }
//
//  data = {
//    database_url = heroku_app.db-hoster.all_config_vars.DATABASE_URL
//  }
//
//  type = "Opaque"
//}

resource "kubernetes_deployment" "lb" {
  metadata {
    name = "something"
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
          image = "nginxdemos/hello"
          name = "gcr"
          port {
            container_port = 80
          }
//          env {
//            name = "DATABASE_URL"
//            value_from {
//              secret_key_ref {
//                name = "app-database-url"
//                key = "database_url"
//              }
//            }
//          }
        }
        image_pull_secrets {
          name = "gcr-json-key"
        }
      }
    }
  }
}
//
//resource "kubernetes_service" "lb" {
//  metadata {
//    name = "something"
//  }
//  spec {
//    selector = {
//      app = local.app_name
//    }
//    type = "NodePort"
//    port {
//      node_port = 30201
//      port = 80
//      target_port = 80
//    }
//  }
//}

output "result" {
  value = {
    "local": local.app_name,
    "actual": kubernetes_deployment.lb.spec.0.template.0.metadata.0.labels.app,
  }
}