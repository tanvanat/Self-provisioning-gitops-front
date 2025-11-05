# 1.1) สร้าง Network
resource "openstack_networking_network_v2" "network" {
    name     = "network_NON"
    external = false
}

# 1.2) สร้าง Subnet
resource "openstack_networking_subnet_v2" "subnet" {
    name            = "subnet_NON"
    network_id      = openstack_networking_network_v2.network.id
    cidr            = "10.10.1.0/24"  
    gateway_ip      = "10.10.1.1"
    dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

# 1.3) สร้าง Security Group
resource "openstack_networking_secgroup_v2" "secgroup" {
    name        = "secgroup_NON"
    description = "Security group for master and worker VMs"
}

# Rule สำหรับอนุญาตการเข้าถึง SSH จากทุก IP
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_1" {
    direction         = "ingress"
    ethertype         = "IPv4"
    protocol          = "tcp"
    port_range_min    = 22
    port_range_max    = 22
    remote_ip_prefix  = "0.0.0.0/0"
    security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

# Rule สำหรับอนุญาตการเข้าถึง Kubernetes API
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_2" {
    direction         = "ingress"
    ethertype         = "IPv4"
    protocol          = "tcp"
    port_range_min    = 6443
    port_range_max    = 6443
    remote_ip_prefix  = "0.0.0.0/0"
    security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

# Rule สำหรับ NodePort เข้าถึง port 30000-32767 จากภายนอก
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_nodeport" {
    direction         = "ingress"
    ethertype         = "IPv4"
    protocol          = "tcp"
    port_range_min    = 30000
    port_range_max    = 32767
    remote_ip_prefix  = "0.0.0.0/0"
    security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

# Rule สำหรับ ping
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_3" {
    direction         = "ingress"
    ethertype         = "IPv4"
    protocol          = "icmp"
    remote_ip_prefix  = "0.0.0.0/0"
    security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

# --------------------- Master / Control Plane --------------------- 

# 1.4) สร้าง Port
resource "openstack_networking_port_v2" "port_master" {
    count      = 1
    name       = "port-master-${count.index + 1}-NON"
    network_id = openstack_networking_network_v2.network.id
    fixed_ip {
        subnet_id = openstack_networking_subnet_v2.subnet.id
    }
    security_group_ids = [openstack_networking_secgroup_v2.secgroup.id]
}

# 1.5) สร้าง Floating IP
resource "openstack_networking_floatingip_v2" "floatip_master" {
    pool = var.public_ip_pool_name_non
}

# 1.6) สร้าง Instance
resource "openstack_compute_instance_v2" "master" {
    count             = 1
    name              = "Master-NON"
    image_name        = var.image_name
    flavor_name       = var.flavor_name
    key_pair          = var.keypair_name
    security_groups   = [openstack_networking_secgroup_v2.secgroup.name]
    availability_zone = var.availability_zone_non

    network {
        port = openstack_networking_port_v2.port_master[0].id
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
        openstack_networking_subnet_v2.subnet,
        openstack_networking_network_v2.network
    ]
}

# 1.7) เชื่อมโยง Floating IP กับ Port
resource "openstack_networking_floatingip_associate_v2" "fip_master" {
    floating_ip = openstack_networking_floatingip_v2.floatip_master.address
    port_id     = openstack_networking_port_v2.port_master[0].id
    depends_on  = [openstack_compute_instance_v2.master]
    }

# --------------------- Worker --------------------- 

# 1.4) สร้าง Port
resource "openstack_networking_port_v2" "port_worker" {
    count      = 2   
    name       = "port-worker-${count.index + 1}-NON"
    network_id = openstack_networking_network_v2.network.id
    fixed_ip {
        subnet_id = openstack_networking_subnet_v2.subnet.id
    }
    security_group_ids = [openstack_networking_secgroup_v2.secgroup.id]
}

# 1.5) สร้าง Floating IP
resource "openstack_networking_floatingip_v2" "floatip_worker" {
    count = 2
    pool  = var.public_ip_pool_name_non
}

resource "openstack_compute_instance_v2" "worker" {
    count             = 2
    name              = "Worker-${count.index + 1}-NON"
    image_name        = var.image_name
    flavor_name       = var.flavor_name
    key_pair          = var.keypair_name
    security_groups   = [openstack_networking_secgroup_v2.secgroup.name]
    availability_zone = var.availability_zone_non

    network {
        port = openstack_networking_port_v2.port_worker[count.index].id
    }

    block_device {
        uuid                  = var.image_id
        source_type           = "image"
        boot_index            = 0
        destination_type      = "volume"
        volume_size           = 50
        delete_on_termination = false
    }

    depends_on = [
        openstack_networking_subnet_v2.subnet,
        openstack_networking_network_v2.network
    ]
}

# 1.7) เชื่อมโยง Floating IP กับ Worker แต่ละตัว
resource "openstack_networking_floatingip_associate_v2" "fip_worker" {
    count       = 2
    floating_ip = openstack_networking_floatingip_v2.floatip_worker[count.index].address
    port_id     = openstack_networking_port_v2.port_worker[count.index].id
    depends_on  = [openstack_compute_instance_v2.worker]
}