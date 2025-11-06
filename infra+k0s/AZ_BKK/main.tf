###############################################
# 1) Network + Subnet + Router (with external GW)
###############################################

resource "openstack_networking_network_v2" "network" {
  name     = "network_BKK"
  external = false
}

resource "openstack_networking_subnet_v2" "subnet" {
  name            = "subnet_BKK"
  network_id      = openstack_networking_network_v2.network.id
  cidr            = "10.10.1.0/24"
  gateway_ip      = "10.10.1.1"
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

# External (public) network used by router gateway
data "openstack_networking_network_v2" "external" {
  name     = var.external_network_name_bkk
  external = true
}

resource "openstack_networking_router_v2" "router" {
  name                = "router_BKK"
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_router_interface_v2" "router_iface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnet.id
}

###############################################
# 2) Security Group + Rules
###############################################
resource "openstack_networking_secgroup_v2" "secgroup" {
  name        = "secgroup_BKK"
  description = "Security group for master and worker VMs"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_k8s" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_nodeport" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 30000
  port_range_max    = 32767
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

###############################################
# 3) Ports
###############################################
resource "openstack_networking_port_v2" "port_master" {
  name       = "port-master-1-BKK"
  network_id = openstack_networking_network_v2.network.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet.id
  }

  security_group_ids = [openstack_networking_secgroup_v2.secgroup.id]
}

resource "openstack_networking_port_v2" "port_worker" {
  count      = 2
  name       = "port-worker-${count.index + 1}-BKK"
  network_id = openstack_networking_network_v2.network.id

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet.id
  }

  security_group_ids = [openstack_networking_secgroup_v2.secgroup.id]
}

###############################################
# 4) Servers (BOOT FROM VOLUME – clean)
###############################################
resource "openstack_compute_instance_v2" "master" {
  name        = "Master-BKK"
  flavor_name = var.flavor_name
  key_pair    = var.keypair_name
  # image_id        = var.image_id   # <-- ตัดทิ้ง เมื่อใช้ block_device
  security_groups   = [openstack_networking_secgroup_v2.secgroup.name]
  availability_zone = "NCP-BKK" # ถ้าเจอปัญหา scheduling ลองคอมเมนต์ทิ้งให้ auto-schedule

  network {
    port = openstack_networking_port_v2.port_master.id
    # ห้ามใส่ uuid ถ้ามี port อยู่แล้ว
  }

  block_device {
    uuid             = var.image_id # Glance image ID
    source_type      = "image"
    destination_type = "volume"
    volume_size      = 40
    # boot_index            = 0
    delete_on_termination = true
    volume_type           = var.volume_type # คอมเมนต์ไว้ก่อน จนกว่าจะชัวร์ว่ามี
  }
}

resource "openstack_compute_instance_v2" "worker" {
  count       = 2
  name        = "Worker-${count.index + 1}-BKK"
  flavor_name = var.flavor_name
  key_pair    = var.keypair_name
  # image_id        = var.image_id
  security_groups   = [openstack_networking_secgroup_v2.secgroup.name]
  availability_zone = "NCP-BKK"

  network {
    port = openstack_networking_port_v2.port_worker[count.index].id
  }

  block_device {
    uuid                  = var.image_id
    source_type           = "image"
    destination_type      = "volume"
    volume_size           = 60
    boot_index            = 0
    delete_on_termination = true
    volume_type           = var.volume_type
  }
}

###############################################
# 5) Floating IPs – create+attach (POST) + ignore PUT
###############################################
resource "openstack_networking_floatingip_v2" "floatip_master" {
  pool    = var.public_ip_pool_name_bkk
  port_id = openstack_networking_port_v2.port_master.id

  lifecycle {
    ignore_changes = [port_id]
  }

  depends_on = [
    openstack_networking_router_interface_v2.router_iface,
    openstack_compute_instance_v2.master
  ]
}

resource "openstack_networking_floatingip_v2" "floatip_worker" {
  count   = 2
  pool    = var.public_ip_pool_name_bkk
  port_id = openstack_networking_port_v2.port_worker[count.index].id

  lifecycle {
    ignore_changes = [port_id]
  }

  depends_on = [
    openstack_networking_router_interface_v2.router_iface,
    openstack_compute_instance_v2.worker
  ]
}
