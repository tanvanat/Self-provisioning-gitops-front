# ใช้ของเดิมที่สร้างไว้เเล้วใน NON
data "openstack_networking_network_v2" "network" { 
    name = "network_NON"
}
data "openstack_networking_subnet_v2"  "subnet"  { 
    name = "subnet_NON"
}
data "openstack_networking_secgroup_v2" "secgroup" { 
    name = "secgroup_NON"
}

# สร้าง Port
resource "openstack_networking_port_v2" "port_argocd" {
    name       = "port-argoCD-NON"
    network_id = data.openstack_networking_network_v2.network.id
    fixed_ip {
        subnet_id = data.openstack_networking_subnet_v2.subnet.id
    }
    security_group_ids = [data.openstack_networking_secgroup_v2.secgroup.id]
}

# สร้าง Floating IP
resource "openstack_networking_floatingip_v2" "floatip_argocd" {
    pool = var.public_ip_pool_name_non
}

# สร้าง instance/VM
resource "openstack_compute_instance_v2" "argocd" {
    name              = "ArgoCD-NON"
    image_name        = var.image_name
    flavor_name       = var.flavor_name
    key_pair          = var.keypair_name
    availability_zone = var.availability_zone_non

    network {
        port = openstack_networking_port_v2.port_argocd.id
    }

    block_device {
        uuid                  = var.image_id
        source_type           = "image"
        boot_index            = 0
        destination_type      = "volume"
        volume_size           = var.volume_size
        delete_on_termination = false
    }

    depends_on = [
        openstack_networking_port_v2.port_argocd
    ]
}

# เชื่อมโยง Floating IP
resource "openstack_networking_floatingip_associate_v2" "fip_argocd" {
    floating_ip = openstack_networking_floatingip_v2.floatip_argocd.address
    port_id     = openstack_networking_port_v2.port_argocd.id
    depends_on  = [openstack_compute_instance_v2.argocd]
}