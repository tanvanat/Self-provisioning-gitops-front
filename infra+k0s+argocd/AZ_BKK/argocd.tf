############################################################
# Argo CD Deployment via Terraform + Helm
# Works with existing kubeconfig (k0s NON cluster)
############################################################

# 1️⃣ Wait a bit to ensure kubeconfig/cluster is ready
resource "time_sleep" "after_kubeconfig" {
  create_duration = "10s"
}

# 2️⃣ Create the ArgoCD namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

# 3️⃣ Install ArgoCD using Helm
resource "helm_release" "argocd" {
  depends_on = [
    time_sleep.after_kubeconfig,
    kubernetes_namespace.argocd
  ]

  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  timeout    = 600
  wait       = true

  # ✅ You can modify these values later (NodePort, Ingress, etc.)
  values = [
    <<-EOT
    server:
      service:
        type: ClusterIP
      ingress:
        enabled: false
    controller:
      args:
        appResyncPeriod: 30
    EOT
  ]
}

# 4️⃣ Read initial admin secret after Helm install completes
data "kubernetes_secret" "argocd_initial_admin" {
  depends_on = [helm_release.argocd]

  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = var.argocd_namespace
  }
}
