variable "harbor_ns" {
  default = "harbor"
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}


resource "kubectl_manifest" "harbor_namespace" {
   yaml_body = <<YAML
apiVersion: v1
kind: Namespace
labels:
  kubernetes.io/metadata.name: ${var.harbor_ns}
  name: ${var.harbor_ns}
metadata:
  name: ${var.harbor_ns}
YAML
}


resource "helm_release" "harbor" {
  depends_on       = [kubectl_manifest.harbor_namespace]
  name  = "harbor"
  namespace        = var.harbor_ns
  create_namespace = false
  max_history      = 3
  wait             = true
  repository = "https://helm.goharbor.io"
  chart      = "harbor"

  set {
    name  = "expose.tls.certSource"
    value = "secret"
  }
  set {
    name  = "expose.ingress.hosts.core"
    value = "${var.domain}"
  }
    set {
    name  = "externalURL"
    value = "https://${var.domain}"
  }
    set_sensitive {
    name  = "harborAdminPassword"
    value = "password"
  }

}

terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}
