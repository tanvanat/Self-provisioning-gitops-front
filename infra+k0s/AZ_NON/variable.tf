variable "external_network_name_non" {
  description = "Public/external network name for router gateway (e.g. Standard_Public_IP_Pool_BKK)"
  type        = string
  default     = "Standard_Public_IP_Pool_NON"
}
variable "public_ip_pool_name_non" {
  description = "Floating IP pool name (e.g. Standard_Public_IP_Pool_BKK)"
  type        = string
  default     = "Standard_Public_IP_Pool_NON"
}
# Image / Flavors / Keypair / Volumes
variable "image_id" {
  description = "Image ID for boot volume"
  type        = string
  default     = "1d0784d3-6b53-4a99-8e4f-35cd91a512fa"
}

variable "image_name" {
  description = "Image name for boot volume"
  type        = string
  default     = "ubuntu-24-v250303"
}
variable "volume_type" {
  type    = string
  default = "Standard_SSD"
}
variable "flavor_name" {
  description = "Flavor for master and worker"
  type        = string
  default     = "csa.2xlarge.v2"
}

variable "keypair_name" {
  description = "Keypair for master and worker"
  type        = string
  default     = "KeyPair"
}
# Availability Zones / IP Pools
variable "availability_zone_non" {
  description = "AZ for NON"
  type        = string
  default     = "NCP-NON"
}

# SSH
variable "ssh_user" {
  description = "SSH username for instances"
  type        = string
  default     = "nc-user"
}

variable "private_key_path" {
  description = "Path to your private SSH key"
  type        = string
  default     = "~/.ssh/KeyPair.pem"
}

# --------------------- Set up instance ---------------------

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