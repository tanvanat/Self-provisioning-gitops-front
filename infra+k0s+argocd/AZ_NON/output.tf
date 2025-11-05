# Output (Private IP)
output "argocd_private_ip" {
    value = openstack_networking_port_v2.port_argocd.all_fixed_ips[0]
}

# Output (Public IP)
output "argocd_floating_ip" {
    value = openstack_networking_floatingip_v2.floatip_argocd.address
}

# รหัส admin จาก secret 
output "argocd_initial_admin_password" {
    value     = base64decode(try(data.kubernetes_secret.argocd_initial_admin.data["password"], ""))
    sensitive = true
}