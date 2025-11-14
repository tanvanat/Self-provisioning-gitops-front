# Render haproxy.cfg จาก template โดยใช้ ingress_ip จาก Kubernetes
locals {
  haproxy_cfg = templatefile("${path.module}/haproxy.cfg.tpl", {
    ingress_ip = local.ingress_ip
  })
}
