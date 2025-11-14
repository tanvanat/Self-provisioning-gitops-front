output "haproxy_bkk_public_ip" {
  description = "Public floating IP for HAProxy in BKK"
  value       = data.openstack_networking_floatingip_v2.existing_haproxy_fip.address
}

output "haproxy_bkk_private_ip" {
  description = "Private IP of HAProxy VM in BKK"
  value       = openstack_compute_instance_v2.haproxy_bkk.network[0].fixed_ip_v4
}
