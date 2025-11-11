resource "openstack_networking_network_v2" "network" {
  name     = "network_NON"
  external = false
}

resource "openstack_networking_subnet_v2" "subnet" {
  name            = "subnet_NON"
  network_id      = openstack_networking_network_v2.network.id
  cidr            = "10.10.2.0/24" #ห้ามเหมือนsubnet_BKK
  gateway_ip      =  "10.10.2.1" #ห้ามเหมือนsubnet_BKK
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

data "openstack_networking_network_v2" "external" {
  name     = var.external_network_name_non
  external = true
}

resource "openstack_networking_router_v2" "router" {
  name                = "router_NON"
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_router_interface_v2" "router_iface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnet.id
}

###############################################
# Security Group + Rules
###############################################
resource "openstack_networking_secgroup_v2" "secgroup" {
  name        = "secgroup_NON"
  description = "Security group for NON cluster"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_egress_all" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = null
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}


resource "openstack_networking_secgroup_rule_v2" "k8s_api" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "nodeport" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 30000
  port_range_max    = 32767
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}
data "openstack_networking_secgroup_v2" "default" {
  name = "default"
}
###############################################
# Ports + Floating IPs
###############################################
resource "openstack_networking_port_v2" "port_master" {
  name       = "port-master-NON"
  network_id = openstack_networking_network_v2.network.id

  fixed_ip { subnet_id = openstack_networking_subnet_v2.subnet.id }
  security_group_ids = [
    openstack_networking_secgroup_v2.secgroup.id,        # secgroup_NON
    data.openstack_networking_secgroup_v2.default.id     # default (optional but recommended)
  ]
}

resource "openstack_networking_port_v2" "port_worker" {
  count      = 2
  name       = "port-worker-${count.index + 1}-NON"
  network_id = openstack_networking_network_v2.network.id

  fixed_ip { subnet_id = openstack_networking_subnet_v2.subnet.id }
  security_group_ids = [
    openstack_networking_secgroup_v2.secgroup.id,
    data.openstack_networking_secgroup_v2.default.id
  ]
}

# resource "openstack_networking_floatingip_v2" "floatip_master" {
#   pool        = var.public_ip_pool_name_non
#   port_id     = openstack_networking_port_v2.port_master.id
#   description = "ExternalIP-Master-NON"

#   depends_on = [openstack_networking_router_interface_v2.router_iface]

#   lifecycle { ignore_changes = [port_id] }
# }

# resource "openstack_networking_floatingip_v2" "floatip_worker" {
#   count       = 2
#   pool        = var.public_ip_pool_name_non
#   port_id     = openstack_networking_port_v2.port_worker[count.index].id
#   description = "ExternalIP-Worker-${count.index + 1}-NON"

#   depends_on = [openstack_networking_router_interface_v2.router_iface]

#   lifecycle { ignore_changes = [port_id] }
# }

###############################################
# Compute Instances (with cloud-init)
###############################################
resource "openstack_compute_instance_v2" "master" {
  name              = "Master-NON"
  flavor_name       = var.flavor_name
  key_pair          = var.keypair_name
  security_groups   = [openstack_networking_secgroup_v2.secgroup.name, "default"]
  availability_zone = var.availability_zone_non

  network { port = openstack_networking_port_v2.port_master.id }

  block_device {
    uuid                  = var.image_id
    source_type           = "image"
    destination_type      = "volume"
    volume_size           = 40
    boot_index            = 0
    delete_on_termination = true
    volume_type           = var.volume_type
  }

  user_data = templatefile("${path.module}/cloud-init.tpl", {
    hostname = "master-non"
  })
}

resource "openstack_compute_instance_v2" "worker" {
  count             = 2
  name              = "Worker-${count.index + 1}-NON"
  flavor_name       = var.flavor_name
  key_pair          = var.keypair_name
  security_groups   = [openstack_networking_secgroup_v2.secgroup.name, "default"]
  availability_zone = var.availability_zone_non

  network { port = openstack_networking_port_v2.port_worker[count.index].id }

  block_device {
    uuid                  = var.image_id
    source_type           = "image"
    destination_type      = "volume"
    volume_size           = 60
    boot_index            = 0
    delete_on_termination = true
    volume_type           = var.volume_type
  }

  user_data = templatefile("${path.module}/cloud-init.tpl", {
    hostname = "worker-${count.index + 1}-non"
  })
}