############################################################
# Load existing network resources (BKK)
############################################################

data "openstack_networking_network_v2" "network_bkk" {
  name = "network_BKK"
}

data "openstack_networking_subnet_v2" "subnet_bkk" {
  name = "subnet_BKK"
}

data "openstack_networking_secgroup_v2" "secgroup_bkk" {
  name = "secgroup_BKK" # ต้องเปิด 22, 80, 443
}

############################################################
# BKK: Port + Instance + Floating IP
############################################################

resource "openstack_networking_port_v2" "port_haproxy_bkk" {
  name           = "port-haproxy-bkk"
  network_id     = data.openstack_networking_network_v2.network_bkk.id
  admin_state_up = true

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.subnet_bkk.id
    ip_address = "10.10.1.7"      # ✅ บังคับใช้ IP นี้
  }

  security_group_ids = [
    data.openstack_networking_secgroup_v2.secgroup_bkk.id
  ]
}

resource "openstack_compute_instance_v2" "haproxy_bkk" {
  name              = "HAProxy-BKK"
  flavor_name       = var.flavor_name
  key_pair          = var.keypair_name
  availability_zone = var.availability_zone_bkk

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
    port = openstack_networking_port_v2.port_haproxy_bkk.id
  }

  # cloud-init ติดตั้ง haproxy และเขียน config
  user_data = templatefile("${path.module}/cloud-init-haproxy.tpl", {
    hostname                = "haproxy-bkk"
    cluster_bkk_ingress_ips = var.cluster_bkk_ingress_ips
  })

  depends_on = [
    openstack_networking_port_v2.port_haproxy_bkk
  ]
}

data "openstack_networking_floatingip_v2" "existing_haproxy_fip" {
  address = "103.212.37.30"  # ✅ ใส่ IP ที่มีอยู่จริง
}
