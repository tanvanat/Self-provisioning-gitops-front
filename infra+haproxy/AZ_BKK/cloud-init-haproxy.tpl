#cloud-config

package_update: true
package_upgrade: true

packages:
  - haproxy

write_files:
  - path: /etc/haproxy/haproxy.cfg
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
          option forwardfor
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
  - systemctl start haproxy

final_message: "HAProxy installed and configured successfully"