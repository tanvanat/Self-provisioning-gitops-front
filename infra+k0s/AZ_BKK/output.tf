output "master_floating_ip" {
  value = openstack_networking_floatingip_v2.floatip_master.address
}

output "worker_floating_ips" {
  value = openstack_networking_floatingip_v2.floatip_worker[*].address
}

output "master_private_ip" {
  value = openstack_networking_port_v2.port_master.all_fixed_ips[0]
}

output "worker_private_ips" {
  value = [for p in openstack_networking_port_v2.port_worker : p.all_fixed_ips[0]]
}
