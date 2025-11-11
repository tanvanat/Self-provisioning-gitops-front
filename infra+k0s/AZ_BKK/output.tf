# Master (BKK)
output "master_private_ip" {
  value = openstack_networking_port_v2.port_master.all_fixed_ips[0]
}

output "master_floating_ip" {
  value = local.master_public_ip_bkk
}

# Workers (BKK)
output "worker_private_ips" {
  value = [for p in openstack_networking_port_v2.port_worker : p.all_fixed_ips[0]]
}

output "worker_floating_ips" {
  value = [
    local.worker1_public_ip_bkk,
    local.worker2_public_ip_bkk,
  ]
}
