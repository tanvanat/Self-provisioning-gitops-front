### หมายเหตุ : ภายในเครื่องไม่มี ArgoCD  CLI ต้องติดตั้งเพิ่งเอง

## ช่วงที่ 1 : สร้าง VM
```base
terraform apply \
  -target=openstack_networking_port_v2.port_argocd \
  -target=openstack_compute_instance_v2.argocd \
  -target=openstack_networking_floatingip_v2.floatip_argocd \
  -target=openstack_networking_floatingip_associate_v2.fip_argocd \
  -target=null_resource.seed_known_hosts \
  -target=null_resource.wait_ssh 


  -target=k0s_cluster.k0s \
  -target=null_resource.export_kubeconfig_remote \
  -target=null_resource.fetch_kubeconfig
```

## ช่วงที่ 2 : ติดตั้ง k0s + ดึง kubeconfig + ลง Argo CD
```base
    terraform apply
```