provider "kubernetes" {
  config_path    = "/etc/rancher/k3s/k3s.yaml"
  config_context = "default"
}

resource "kubernetes_namespace" "example" {
  metadata {
    name = "my-first-namespace"
  }
}

# ArgoCD namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# ArgoCD installation using kubectl provider
resource "kubernetes_manifest" "argocd_install" {
  depends_on = [kubernetes_namespace.argocd]
  
  manifest = {
    apiVersion = "v1"
    kind       = "ConfigMap"
    metadata = {
      name      = "argocd-install"
      namespace = "argocd"
    }
    data = {
      install = "kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
    }
  }
}

# We'll use a null_resource to actually install ArgoCD
resource "null_resource" "install_argocd" {
  depends_on = [kubernetes_namespace.argocd]
  
  provisioner "local-exec" {
    command = "kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
  }
  
  triggers = {
    namespace_id = kubernetes_namespace.argocd.id
  }
}
