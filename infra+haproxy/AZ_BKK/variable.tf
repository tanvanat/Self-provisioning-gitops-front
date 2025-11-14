variable "flavor_name" {
  description = "OpenStack flavor for HAProxy VM in BKK"
  type        = string
  default     = "csa.2xlarge.v2"
}

variable "image_id" {
  description = "Glance image ID to boot from"
  type        = string
  default     = "1d0784d3-6b53-4a99-8e4f-35cd91a512fa"
}

variable "volume_size" {
  description = "Root volume size (GB)"
  type        = number
  default     = 50
}

variable "volume_type" {
  description = "Cinder volume type for root disk"
  type        = string
  default     = "Standard_SSD"
}

variable "keypair_name" {
  description = "Existing OpenStack keypair name"
  type        = string
  default     = "KeyPair"
}

variable "private_key_path" {
  description = "Path to private SSH key for the keypair"
  type        = string
  default     = "~/.ssh/KeyPair.pem"
}

variable "availability_zone_bkk" {
  description = "Availability zone for BKK"
  type        = string
  default     = "NCP-BKK"
}

variable "public_ip_pool_name_bkk" {
  description = "Name of public IP pool in BKK (if needed)"
  type        = string
  default     = "Standard_Public_IP_Pool_BKK"
}

# IP ปลายทาง ingress ของ k0s แต่ละฝั่ง (ใช้ใน cloud-init)
variable "cluster_bkk_ingress_ips" {
  description = "Ingress IPs of all BKK worker nodes"
  type        = list(string)
  default     = [
    "10.10.1.4",
    "10.10.1.2",
  ]
}

variable "ssh_user" {
  description = "Default SSH user for Ubuntu cloud images"
  type        = string
  default     = "nc-user"
}

variable "image_name" {
  description = "Image name for boot volume (optional, not used directly)"
  type        = string
  default     = "ubuntu-24-v250303"
}

variable "worker_internal_ips" {
  description = "Map from worker node name to internal IP (for kube ingress node)"
  type        = map(string)
  default = {
    worker-1-bkk = "10.10.1.4"
    worker-2-bkk = "10.10.1.2"
  }
}
