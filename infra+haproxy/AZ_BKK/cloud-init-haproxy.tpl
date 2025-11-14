#cloud-config

hostname: ${hostname}
manage_etc_hosts: true

package_update: true
package_upgrade: true

packages:
  - haproxy

write_files:
  - path: /etc/haproxy/haproxy.cfg
    owner: root:root
    permissions: "0644"
    content: |
      global
          daemon
          maxconn 4000
          log /dev/log local0

      defaults
          mode http
          timeout connect 5000ms
          timeout client 50000ms
          timeout server 50000ms
          log global

      frontend http_front
          bind *:80
          default_backend k8s_workers

      backend k8s_workers
          balance roundrobin
          %{ for ip in cluster_bkk_ingress_ips ~}
          server worker_${replace(ip, ".", "_")} ${ip}:80 check
          %{ endfor ~}

      listen stats
          bind *:8404
          stats enable
          stats uri /
          stats refresh 5s

runcmd:
  - systemctl enable haproxy
  - systemctl restart haproxy

final_message: "HAProxy installed and configured successfully"
