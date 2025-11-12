# Output (Private IP)
output "argocd_private_ip" {
    value = openstack_networking_port_v2.port_argocd.all_fixed_ips[0]
}

# Output (Public IP)
output "argocd_floating_ip" {
    value = data.openstack_networking_floatingip_v2.existing_argocd_fip.address
}

output "argocd_initial_admin_password" {
  value     = try(data.kubernetes_secret.argocd_initial_admin.data["password"], null)
  sensitive = true
}