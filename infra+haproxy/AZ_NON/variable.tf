variable "flavor_name" { default = "csa.2xlarge.v2" }
variable "image_id" { default = "1d0784d3-6b53-4a99-8e4f-35cd91a512fa" }
variable "volume_size" { default = 50 }
variable "volume_type" { default = "Standard_SSD" }
variable "keypair_name" { default = "KeyPair" }
variable "private_key_path" { default = "~/.ssh/KeyPair.pem"}
variable "availability_zone_non" { default = "NCP-NON" }

variable "public_ip_pool_name_non" { default = "Standard_Public_IP_Pool_NON" }

# IP ปลายทาง ingress ของ k0s แต่ละฝั่ง
# variable "cluster_bkk_ingress_ips" {
#   description = "Ingress IPs of all BKK worker nodes"
#   type        = list(string)
#   default     = [
#     # ถ้าเราstop instanceไปตัวนึงnode selectorจะมีการเลือกinstanceใหม่ภายในclusterนั้นเอง
#     # เเต่เราไม่รู้ว่าnode selectorเลือกอะไรเพื่อให้haproxyเชื่อมกับingress controllerที่ติดตั้งบนinstanceนั้นได้เลยใส่2ip
#     "103.212.36.226", # Worker-1-BKK
#     "103.29.189.79"   # Worker-2-BKK
#   ]
# }
variable "ssh_user" {
  description = "Default SSH user for Ubuntu cloud images"
  type        = string
  default     = "nc-user"
}
variable "image_name" {
  description = "Image name for boot volume"
  type        = string
  default     = "ubuntu-24-v250303"
}