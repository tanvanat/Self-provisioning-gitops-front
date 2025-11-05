# 2.1) seed_known_hosts = กัน fail เวลา IP ยังไม่ตอบ 
resource "null_resource" "seed_known_hosts" {
    triggers = {
        master      = openstack_networking_floatingip_v2.floatip_master.address
        worker1     = openstack_networking_floatingip_v2.floatip_worker[0].address
        worker2     = openstack_networking_floatingip_v2.floatip_worker[1].address
    }

    provisioner "local-exec" {
        interpreter = ["/bin/bash","-lc"]
        command = <<-EOT
        set +e
        for ip in ${self.triggers.master} ${self.triggers.worker1} ${self.triggers.worker2}; do
            ssh-keygen -R "$ip" >/dev/null 2>&1 || true
            ssh-keyscan -T 3 -H "$ip" >> ~/.ssh/known_hosts 2>/dev/null || true
        done
        EOT
    }
}

# 2.2) ติดตั้ง k0s cluster
resource "k0s_cluster" "k0s" {
    depends_on = [null_resource.seed_known_hosts]
    name    = "k0s-cluster-BKK"
    version = "1.29.4+k0s.0"

    hosts = [
        {
        role = "controller"
        ssh = {
            address  = openstack_networking_floatingip_v2.floatip_master.address
            port     = 22
            user     = var.ssh_user
            key_path = var.private_key_path
        }
        },
        {
        role = "worker"
        ssh = {
            address  = openstack_networking_floatingip_v2.floatip_worker[0].address
            port     = 22
            user     = var.ssh_user
            key_path = var.private_key_path
        }
        },
        {
        role = "worker"
        ssh = {
            address  = openstack_networking_floatingip_v2.floatip_worker[1].address
            port     = 22
            user     = var.ssh_user
            key_path = var.private_key_path
        }
        }
    ]
}