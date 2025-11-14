resource "null_resource" "upload_haproxy_config" {
  # ถ้า ingress_ip เปลี่ยน ให้ re-run provisioner
  triggers = {
    ingress_ip = local.ingress_ip
  }

  connection {
    host        = openstack_compute_instance_v2.haproxy_bkk.network[0].fixed_ip_v4
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.private_key_path)
  }

  # อัปโหลดไฟล์ haproxy.cfg ที่ render แล้วขึ้นไปบน VM
  provisioner "file" {
    content     = local.haproxy_cfg
    destination = "/tmp/haproxy.cfg"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/haproxy.cfg /etc/haproxy/haproxy.cfg",
      "sudo systemctl restart haproxy",
    ]
  }

  depends_on = [
    openstack_compute_instance_v2.haproxy_bkk,
    openstack_compute_floatingip_associate_v2.haproxy_bkk_fip_assoc,
  ]
}
