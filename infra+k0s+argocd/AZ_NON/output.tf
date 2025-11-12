output "argocd_private_ip" {
  value = openstack_networking_port_v2.port_argocd.fixed_ip[0].ip_address
}

output "argocd_floating_ip" {
  value = data.openstack_networking_floatingip_v2.existing_argocd_fip.address
}

output "argocd_initial_admin_password" {
  value     = data.kubernetes_secret.argocd_initial_admin.data["password"]
  sensitive = true
}