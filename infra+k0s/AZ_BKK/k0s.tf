###############################################
# 2.1) Seed known_hosts (avoid first-time SSH delays)
###############################################
resource "null_resource" "seed_known_hosts" {
  triggers = {
    master  = openstack_networking_floatingip_v2.floatip_master.address
    worker1 = openstack_networking_floatingip_v2.floatip_worker[0].address
    worker2 = openstack_networking_floatingip_v2.floatip_worker[1].address
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-lc"]
    command = "set +e; for ip in ${self.triggers.master} ${self.triggers.worker1} ${self.triggers.worker2}; do echo '🔁 Refreshing known_hosts for' $ip; ssh-keygen -R $ip >/dev/null 2>&1 || true; ssh-keyscan -T 5 -H $ip >> ~/.ssh/known_hosts.tmp 2>/dev/null || true; done; awk '/^\\|1|^\\[|^ssh-/' ~/.ssh/known_hosts.tmp > ~/.ssh/known_hosts.clean; mv ~/.ssh/known_hosts.clean ~/.ssh/known_hosts; rm -f ~/.ssh/known_hosts.tmp"
  }
}

###############################################
# 2.1b) Wait until nodes are reachable via SSH
###############################################
resource "null_resource" "wait_for_ssh" {
  depends_on = [
    openstack_networking_floatingip_v2.floatip_master,
    openstack_networking_floatingip_v2.floatip_worker
  ]

  triggers = {
    master  = openstack_networking_floatingip_v2.floatip_master.address
    worker1 = openstack_networking_floatingip_v2.floatip_worker[0].address
    worker2 = openstack_networking_floatingip_v2.floatip_worker[1].address
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-lc"]
    command = "echo '⏳ Waiting for SSH...'; for ip in ${self.triggers.master} ${self.triggers.worker1} ${self.triggers.worker2}; do for i in {1..30}; do ssh -o StrictHostKeyChecking=no -i ${var.private_key_path} ${var.ssh_user}@$ip 'echo SSH OK' >/dev/null 2>&1 && echo '✅ SSH ready on' $ip && break || echo 'waiting for' $ip '('$i'/30)...' && sleep 10; done; done"
  }
}

###############################################
# 2.2) Install k0s cluster
###############################################
resource "k0s_cluster" "k0s" {
  depends_on = [
    null_resource.seed_known_hosts,
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
