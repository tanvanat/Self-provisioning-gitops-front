#cloud-config
hostname: ${hostname}
manage_etc_hosts: true

bootcmd:
  - rm -f /etc/machine-id
  - systemd-machine-id-setup

runcmd:
  - echo "✅ Machine ID regenerated for $(hostname)"
  - timedatectl set-timezone Asia/Bangkok
  - apt-get update -y
  - apt-get install -y curl jq net-tools
  - echo "Cloud-init finished on $(date)" > /var/log/cloud-init.done
