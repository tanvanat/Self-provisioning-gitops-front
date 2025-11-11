###############################################
# Fixed public IPs (NON)
###############################################
locals {
  master_public_ip_non  = "103.29.190.214"
  worker1_public_ip_non = "103.29.190.215"
  worker2_public_ip_non = "103.29.190.216"
}

###############################################
# 2.1) Seed known_hosts
###############################################
resource "null_resource" "seed_known_hosts" {
  depends_on = [
    openstack_compute_instance_v2.master,
    openstack_compute_instance_v2.worker,
  ]

  triggers = {
    master  = local.master_public_ip_non
    worker1 = local.worker1_public_ip_non
    worker2 = local.worker2_public_ip_non
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-lc"]
    command     = "set -e; for ip in ${self.triggers.master} ${self.triggers.worker1} ${self.triggers.worker2}; do ssh-keygen -R \"$${ip}\" >/dev/null 2>&1 || true; ssh-keyscan -T 10 -H -t rsa,ecdsa,ed25519 \"$${ip}\" >> ~/.ssh/known_hosts 2>/dev/null || true; done"
  }
}

###############################################
# 2.1b) Wait until nodes are reachable via SSH
###############################################
resource "null_resource" "wait_for_ssh" {
  depends_on = [
    null_resource.seed_known_hosts,
  ]

  triggers = {
    master  = local.master_public_ip_non
    worker1 = local.worker1_public_ip_non
    worker2 = local.worker2_public_ip_non
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-lc"]
    command = "set -e; echo 'Waiting for SSH (publickey) on all nodes...'; for ip in ${self.triggers.master} ${self.triggers.worker1} ${self.triggers.worker2}; do ok=0; for i in $(seq 1 40); do if ssh -o BatchMode=yes -o PreferredAuthentications=publickey -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i ${var.private_key_path} ${var.ssh_user}@$${ip} 'echo SSH OK' >/dev/null 2>&1; then echo \"SSH ready on $${ip}\"; ok=1; break; else echo \"waiting for $${ip} ($${i}/40)...\"; sleep 6; fi; done; if [ $ok -ne 1 ]; then echo \"ERROR: SSH not ready on $${ip}\"; exit 1; fi; done; echo 'sleep 20s for cloud-init'; sleep 20"
  }
}

###############################################
# 2.2) Install k0s cluster
###############################################
resource "k0s_cluster" "k0s" {
  depends_on = [
    null_resource.wait_for_ssh,
    openstack_compute_instance_v2.master,
    openstack_compute_instance_v2.worker,
  ]

  name    = "k0s-cluster-NON"
  version = "1.29.4+k0s.0"

  hosts = [
    {
      role = "controller"
      ssh = {
        address  = local.master_public_ip_non
        port     = 22
        user     = var.ssh_user
        key_path = var.private_key_path
      }
    },
    {
      role = "worker"
      ssh = {
        address  = local.worker1_public_ip_non
        port     = 22
        user     = var.ssh_user
        key_path = var.private_key_path
      }
    },
    {
      role = "worker"
      ssh = {
        address  = local.worker2_public_ip_non
        port     = 22
        user     = var.ssh_user
        key_path = var.private_key_path
      }
    },
  ]
}
