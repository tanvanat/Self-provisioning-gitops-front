##############################################
# Load existing resources (use NON cluster)
##############################################
data "openstack_networking_network_v2" "network" {
  name = "network_NON"
}

data "openstack_networking_subnet_v2" "subnet" {
  name = "subnet_NON"   # ✅ ใช้ชื่อ subnet ที่มีอยู่แล้วใน NON
}

data "openstack_networking_secgroup_v2" "secgroup" {
  name = "secgroup_NON" # ✅ ใช้ Security Group ของ NON ที่มีอยู่
}

# ใช้ floating IP เดิม (ถ้ามี)
data "openstack_networking_floatingip_v2" "existing_argocd_fip" {
  address = "103.29.190.222"  # ✅ ใส่ IP ที่มีอยู่จริง
}

##############################################
# Create Port for ArgoCD VM
##############################################
resource "openstack_networking_port_v2" "port_argocd" {
  name           = "port-argocd-non"
  network_id     = data.openstack_networking_network_v2.network.id
  admin_state_up = true

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.subnet.id
  }

  security_group_ids = [data.openstack_networking_secgroup_v2.secgroup.id]
}

##############################################
# Create ArgoCD VM
##############################################
resource "openstack_compute_instance_v2" "argocd" {
  name              = "ArgoCD-NON"
  flavor_name       = var.flavor_name
  key_pair          = var.keypair_name
  availability_zone = var.availability_zone_non

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
    port = openstack_networking_port_v2.port_argocd.id
  }

  # (ถ้ามี cloud-init)
  user_data = templatefile("${path.module}/cloud-init.tpl", {
    hostname       = "argocd-non"
    ssh_public_key = file("~/.ssh/KeyPair.pub")
  })

  depends_on = [openstack_networking_port_v2.port_argocd]
}

##############################################
# Associate existing Floating IP to new instance
##############################################
# resource "openstack_networking_floatingip_associate_v2" "argocd_fip_assoc" {
#   floating_ip = data.openstack_networking_floatingip_v2.existing_argocd_fip.address
#   port_id     = openstack_networking_port_v2.port_argocd.id
# }
