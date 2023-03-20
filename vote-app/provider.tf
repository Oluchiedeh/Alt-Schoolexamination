terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}
#provider "kubernetes" {
#  config_path = "~/.kube/config"
#}

data "aws_eks_cluster" "demo" {
  name = "demo"
}
data "aws_eks_cluster_auth" "demo" {
  name = "demo"
}
provider "kubernetes" {
  host                   = data.aws_eks_cluster.demo.endpoint
  token                  = data.aws_eks_cluster_auth.demo.token 
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.demo.certificate_authority.0.data)
  config_path = "~/.kube/config"
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--demo-name", data.aws_eks_cluster.demo.name]
    command     = "aws"
  }
}

resource "kubernetes_namespace" "voting-app" {
  metadata {
    name = "voting-app"
  }
}
