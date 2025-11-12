##############################################
# Load existing resources (use BKK cluster)
##############################################
data "openstack_networking_network_v2" "network" {
  name = "network_BKK"
}

data "openstack_networking_subnet_v2" "subnet" {
  name = "subnet_BKK"   # ✅ ใช้ชื่อ subnet ที่มีอยู่แล้วใน BKK
}

data "openstack_networking_secgroup_v2" "secgroup" {
  name = "secgroup_BKK" # ✅ ใช้ Security Group ของ BKK ที่มีอยู่
}

# ใช้ floating IP เดิม (ถ้ามี)
data "openstack_networking_floatingip_v2" "existing_argocd_fip" {
  address = "103.29.189.93"  # ✅ ใส่ IP ที่มีอยู่จริง
}

##############################################
# Create Port for ArgoCD VM
##############################################
resource "openstack_networking_port_v2" "port_argocd" {
  name           = "port-argocd-bkk"
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
  name              = "ArgoCD-BKK"
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
    port = openstack_networking_port_v2.port_argocd.id
  }

  # (ถ้ามี cloud-init)
  user_data = templatefile("${path.module}/cloud-init.tpl", {
    hostname       = "argocd-bkk"
    ssh_public_key = file("~/.ssh/KeyPair.pub")
  })

  depends_on = [openstack_networking_port_v2.port_argocd]
}

