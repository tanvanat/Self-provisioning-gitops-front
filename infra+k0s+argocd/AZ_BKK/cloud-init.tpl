#cloud-config
hostname: ${hostname}
manage_etc_hosts: true

package_update: true
package_upgrade: true

packages:
  - curl
  - wget
  - vim
  - htop
  - net-tools

users:
  - name: nc-user
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']

runcmd:
  - timedatectl set-timezone Asia/Bangkok
  - mkdir -p /home/nc-user/.ssh
  - chown -R nc-user:nc-user /home/nc-user