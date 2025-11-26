output "haproxy_bkk_public_ip" {
  value = data.openstack_networking_floatingip_v2.existing_haproxy_fip.address
}
output "haproxy_non_private_ip" {
  value = openstack_compute_instance_v2.haproxy_non.network[0].fixed_ip_v4
}