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
    server ingress ${ingress_ip}:30080 check

listen stats
    bind *:8404
    stats enable
    stats uri /
    stats refresh 5s
