# --------------------- Master / Control Plane --------------------- 

# Output (Private IP)
output "master_private_ip" {
    value = openstack_networking_port_v2.port_master[0].all_fixed_ips[0]
}

# Output (Public IP)
output "master_floating_ip" {
    value = openstack_networking_floatingip_v2.floatip_master.address
}

# --------------------- Worker --------------------- 

# Output (Private IP)
output "worker_private_ip" {
    value = [for p in openstack_networking_port_v2.port_worker : p.all_fixed_ips[0]]
}

# Output (Public IP)
output "worker_floating_ip" {
    value = openstack_networking_floatingip_v2.floatip_worker[*].address
}