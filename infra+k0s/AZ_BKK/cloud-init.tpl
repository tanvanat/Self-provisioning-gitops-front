#cloud-config
preserve_hostname: false
hostname: ${hostname}
fqdn: ${hostname}.local

bootcmd:
  - [bash, -xc, "truncate -s 0 /etc/machine-id || true"]
  - [bash, -xc, "rm -f /var/lib/dbus/machine-id || true"]
  - [bash, -xc, "ln -sf /etc/machine-id /var/lib/dbus/machine-id || true"]

runcmd:
  - [bash, -xc,"systemd-machine-id-setup || true"]
