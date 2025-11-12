# # 2.1) เตรียม SSH/known_hosts + รอพอร์ต 22
# resource "null_resource" "seed_known_hosts" {
#   triggers = { ip = data.openstack_networking_floatingip_v2.existing_argocd_fip.address }

#   provisioner "local-exec" {
#     interpreter = ["/bin/bash", "-lc"]
#     command     = <<-EOT
#       set +e
#       ssh-keygen -R ${self.triggers.ip} >/dev/null 2>&1 || true
#       ssh-keyscan -T 5 -H ${self.triggers.ip} >> ~/.ssh/known_hosts 2>/dev/null || true
#     EOT
#   }
# }

# # 2.2) ติดตั้ง k0s (single node)
# resource "k0s_cluster" "k0s" {
#   name    = "k0s-argoCD-NON"
#   version = "1.34.1"

#   hosts = [
#     {
#       role      = "single"
#       no_taints = true
#       ssh = {
#         address  = data.openstack_networking_floatingip_v2.existing_argocd_fip.address
#         port     = 22
#         user     = var.ssh_user
#         key_path = var.private_key_path
#       }
#     }
#   ]
# }

# # 2.3) สร้าง kubeconfig ที่ instance
# resource "null_resource" "export_kubeconfig_remote" {
#   depends_on = [k0s_cluster.k0s]

#   connection {
#     type        = "ssh"
#     host        = data.openstack_networking_floatingip_v2.existing_argocd_fip.address
#     user        = var.ssh_user
#     private_key = file(var.private_key_path)
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "export PATH=$PATH:/usr/local/bin:/usr/bin:/bin",
#       "for i in {1..30}; do sudo k0s kubectl get nodes >/dev/null 2>&1 && break; sleep 5; done",
#       "sudo cat /var/lib/k0s/pki/admin.conf > ~/kubeconfig.yaml",
#       "chmod 600 ~/kubeconfig.yaml",
#       "sed -E -i 's#server: https://(127\\.0\\.0\\.1|localhost|10\\.[0-9.]+):6443#server: https://${data.openstack_networking_floatingip_v2.existing_argocd_fip.address}:6443#' ~/kubeconfig.yaml",
#       "grep -E '^\\s*server:' ~/kubeconfig.yaml >/dev/null",
#     ]
#   }
# }

# # 2.4) scp กลับมาที่ ./kubeconfig/kubeconfig.yaml
# resource "null_resource" "fetch_kubeconfig" {
#   depends_on = [null_resource.export_kubeconfig_remote]

#   provisioner "local-exec" {
#     interpreter = ["/bin/bash", "-lc"]
#     command     = <<-EOT
#       mkdir -p ${path.module}/config
#       scp -o StrictHostKeyChecking=no -i ${var.private_key_path} \
#           ${var.ssh_user}@${data.openstack_networking_floatingip_v2.existing_argocd_fip.address}:~/kubeconfig.yaml \
#           ${path.module}/config/kubeconfig.yaml
#     EOT
#   }
# }

# # รอให้ kubeconfig พร้อม
# resource "time_sleep" "after_kubeconfig" {
#   depends_on = [null_resource.fetch_kubeconfig]
#   create_duration = "10s"
# }