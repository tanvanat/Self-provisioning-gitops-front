# 3.1) หน่วงเวลาหลังดึง Kubeconfig 
resource "time_sleep" "after_kubeconfig" {
    depends_on = [null_resource.fetch_kubeconfig]
    create_duration = "30s"
}

# 3.2) สร้าง namespace
resource "kubernetes_namespace" "argocd" {
    metadata {  
        name = var.argocd_namespace
    }
}

# 3.3) ติดตั้ง Argo CD
resource "helm_release" "argocd" {
    name             = "argocd"
    repository       = "https://argoproj.github.io/argo-helm"
    chart            = "argo-cd"
    namespace        = kubernetes_namespace.argocd.id
    version          = var.argocd_chart_version
    create_namespace = true

    values = [
      # เเก้ Service Type ให้เป็น NodePort 30080
      file("${path.module}/config/argocd-values.yaml")
    ]

    timeout    = 900
    wait       = true 
    depends_on = [kubernetes_namespace.argocd]
}

# 3.4) อ่านรหัส admin
data "kubernetes_secret" "argocd_initial_admin" {
    metadata {
      name      = "argocd-initial-admin-secret"
      namespace = kubernetes_namespace.argocd.id
    }
    depends_on = [helm_release.argocd]
}