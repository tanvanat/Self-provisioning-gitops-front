# ดึง ingress controller pod จาก cluster
data "kubernetes_pod" "ingress" {
  metadata {
    namespace = "ingress-nginx"
    name      = "ingress-nginx-controller"
  }
}

# แปลง node_name -> internal IP ของ worker จาก var.worker_internal_ips
locals {
  ingress_node = data.kubernetes_pod.ingress.spec[0].node_name
  ingress_ip   = var.worker_internal_ips[local.ingress_node]
}
