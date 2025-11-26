############################################################
# Load existing network resources (NON)
############################################################

data "openstack_networking_network_v2" "network_non" {
  name = "network_NON"
}

data "openstack_networking_subnet_v2" "subnet_non" {
  name = "subnet_NON"
}

data "openstack_networking_secgroup_v2" "secgroup_non" {
  name = "secgroup_NON" # ต้องเปิด 22, 80, 443
}

############################################################
# NON: Port + Instance + Floating IP
############################################################

resource "openstack_networking_port_v2" "port_haproxy_non" {
  name           = "port-haproxy-non"
  network_id     = data.openstack_networking_network_v2.network_non.id
  admin_state_up = true

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.subnet_non.id
    # ip_address = "10.10.1.7"      # ✅ บังคับใช้ IP นี้
  }

  security_group_ids = [
    data.openstack_networking_secgroup_v2.secgroup_non.id
  ]
}

resource "openstack_compute_instance_v2" "haproxy_non" {
  name              = "HAProxy-NON"
  availability_zone = var.availability_zone_non
  flavor_name       = "csa.xlarge.v2"  # ✅ Use a specific flavor name from your list
  key_pair          = var.keypair_name
  image_name        = "Ubuntu 22.04"   # ✅ Specify image name instead of ID

  # Boot from volume so we can control size & type
  block_device {
    uuid                  = var.image_id
    source_type           = "image"
    destination_type      = "volume"
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    port = openstack_networking_port_v2.port_haproxy_non.id
  }

  # cloud-init ติดตั้ง haproxy และเขียน config คร่าว ๆ
  # user_data = templatefile("${path.module}/cloud-init-haproxy.tpl", {
  #   hostname                = "haproxy-non"
  #   cluster_non_ingress_ips = var.cluster_non_ingress_ips
  # })

  depends_on = [
    openstack_networking_port_v2.port_haproxy_non
  ]
}

data "openstack_networking_floatingip_v2" "existing_haproxy_fip" {
  address = "103.29.190.223"  # ✅ ใส่ IP ที่มีอยู่จริง
}