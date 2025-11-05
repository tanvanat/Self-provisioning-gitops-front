# --- Auth ---
variable "os_username"       { type = string }
variable "os_password" { 
    type = string
    sensitive = true 
}
variable "os_project_name"   { type = string }
variable "os_user_domain" { 
    type = string
    default = "nipacloud" 
}
variable "os_project_domain" { 
    type = string
    default = "nipacloud" 
}

# --- External network + FIP pool ---
variable "external_network_name_bkk" {
  description = "Public/external network name for router gateway (e.g. Standard_Public_IP_Pool_BKK)"
  type        = string
}
variable "public_ip_pool_name_bkk" {
  description = "Floating IP pool name (e.g. Standard_Public_IP_Pool_BKK)"
  type        = string
  default = "Standard_Public_IP_Pool_BKK"
}

# --- Image/Flavor (boot-from-image) ---
variable "image_id" {
  description = "Glance image name to boot from (e.g., ubuntu-22-v250307)"
  type        = string
}

variable "volume_size" {
  type        = number
  default     = 100
  description = "Volume size (GB) for control plane nodes"
}

variable "volume_type" {
  type = string
  default = "Standard_SSD"
}
variable "flavor_name" {
  description = "Flavor for master and workers (e.g., csa.large.v2)"
  type        = string
}

# --- Keypair ---
variable "keypair_name" {
  description = "Existing OpenStack keypair name (from `openstack keypair list`)"
  type        = string
}

# --- AZ (optional) ---
variable "availability_zone_bkk" {
  description = "Compute AZ (leave empty to auto-schedule)"
  type        = string
  default     = ""
}

# --- SSH for k0s / manual SSH ---
variable "ssh_user" {
  description = "Default SSH user for Ubuntu cloud images"
  type        = string
  default     = "ubuntu"
}
variable "private_key_path" {
  description = "Path to your local private SSH key file (used for SSH/k0s)"
  type        = string
  default     = "~/.ssh/KeyPair.pem"
}
