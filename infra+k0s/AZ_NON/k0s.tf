###############################################
# 2.1) Seed known_hosts (avoid first-time SSH delays)
###############################################

resource "null_resource" "seed_known_hosts" {
  depends_on = [
    openstack_networking_floatingip_v2.floatip_master,
    openstack_networking_floatingip_v2.floatip_worker,
  ]

  triggers = {
    master  = openstack_networking_floatingip_v2.floatip_master.address
    worker1 = openstack_networking_floatingip_v2.floatip_worker[0].address
    worker2 = openstack_networking_floatingip_v2.floatip_worker[1].address
  }

  provisioner "local-exec" {
    # สำคัญ: ใช้ bash -lc และ heredoc กัน CRLF / token เพี้ยน
    interpreter = ["/bin/bash", "-lc"]
    command     = <<-EOC
      set -e
      echo "Seeding known_hosts for master and workers..."
      for ip in ${self.triggers.master} ${self.triggers.worker1} ${self.triggers.worker2}; do
        echo "Processing $ip"
        ssh-keygen -R "$ip" >/dev/null 2>&1 || true
        ssh-keyscan -T 10 -H -t rsa,ecdsa,ed25519 "$ip" >> "$HOME/.ssh/known_hosts" 2>/dev/null || true
      done
      echo "known_hosts seeding done."
    EOC
  }
}

###############################################
# 2.1b) Wait until nodes are reachable via SSH
###############################################

resource "null_resource" "wait_for_ssh" {
  depends_on = [
    null_resource.seed_known_hosts,
    openstack_compute_instance_v2.master,
    openstack_compute_instance_v2.worker,
  ]

  triggers = {
    master  = openstack_networking_floatingip_v2.floatip_master.address
    worker1 = openstack_networking_floatingip_v2.floatip_worker[0].address
    worker2 = openstack_networking_floatingip_v2.floatip_worker[1].address
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-lc"]
    command = <<-EOC
      set -e
      echo "Waiting for SSH on all nodes..."
      for ip in ${self.triggers.master} ${self.triggers.worker1} ${self.triggers.worker2}; do
        ok=0
        for i in $(seq 1 40); do
          if ssh -o BatchMode=yes \
                -o PreferredAuthentications=publickey \
                -o StrictHostKeyChecking=no \
                -o ConnectTimeout=5 \
                -i ${var.private_key_path} \
                ${var.ssh_user}@$ip "echo SSH OK" >/dev/null 2>&1; then
            echo "SSH ready on $ip"
            ok=1
            break
          else
            echo "waiting for $ip ($i/40)..."
            sleep 6
          fi
        done
        if [ $ok -ne 1 ]; then
          echo "ERROR: SSH not ready on $ip"
          exit 1
        fi
      done
      echo "All nodes reachable, sleep 20s for cloud-init"
      sleep 20
    EOC
  }
}

###############################################
# 2.2) Install k0s cluster (BKK)
###############################################

resource "k0s_cluster" "k0s" {
  depends_on = [
    null_resource.wait_for_ssh,
    openstack_compute_instance_v2.master,
    openstack_compute_instance_v2.worker,
    openstack_networking_floatingip_v2.floatip_master,
    openstack_networking_floatingip_v2.floatip_worker
  ]

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
