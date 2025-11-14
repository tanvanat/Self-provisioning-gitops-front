provider "kubernetes" {
  config_path = "${path.module}/kubeconfig/admin.conf"
}
