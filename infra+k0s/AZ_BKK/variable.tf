# --- External network + FIP pool ---
variable "external_network_name_bkk" {
  description = "Public/external network name for router gateway (e.g. Standard_Public_IP_Pool_BKK)"
  type        = string
  default     = "Standard_Public_IP_Pool_BKK"
}
variable "public_ip_pool_name_bkk" {
  description = "Floating IP pool name (e.g. Standard_Public_IP_Pool_BKK)"
  type        = string
  default     = "Standard_Public_IP_Pool_BKK"
}

# --- Image/Flavor (boot-from-image) ---
variable "image_id" {
  description = "Glance image name to boot from (e.g., ubuntu-22-v250307)"
  type        = string
  default     = "1d0784d3-6b53-4a99-8e4f-35cd91a512fa"
}

variable "volume_type" {
  type    = string
  default = "Standard_SSD"
}
variable "flavor_name" {
  description = "Flavor for master and workers (e.g., csa.large.v2)"
  type        = string
  default     = "csa.2xlarge.v2"
}

# --- Keypair ---
variable "keypair_name" {
  description = "Existing OpenStack keypair name (from `openstack keypair list`)"
  type        = string
  default     = "KeyPair"
}

# --- AZ (optional) ---
variable "availability_zone_bkk" {
  description = "Compute AZ (leave empty to auto-schedule)"
  type        = string
  default     = "NCP-BKK"
}

# --- SSH for k0s / manual SSH ---
variable "ssh_user" {
  description = "SSH username for instances"
  type        = string
  default     = "nc-user"
}
variable "private_key_path" {
  description = "Path to SSH private key"
  type        = string
  default     = "~/.ssh/KeyPair.pem"
}

variable "master_volume_size" {
  type        = number
  description = "Root volume size (GiB) for master"
  default     = 40
}
variable "worker_volume_size" {
  type        = number
  description = "Root volume size (GiB) for each worker"
  default     = 60
}