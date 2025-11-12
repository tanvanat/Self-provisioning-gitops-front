# SSH
variable "ssh_user" {
  description = "Default SSH user for Ubuntu cloud images"
  type        = string
  default     = "nc-user"
}

variable "private_key_path" {
  description = "Path to your private SSH key"
  type        = string
  default     = "~/.ssh/KeyPair.pem"
}

# --------------------- Set up instance ---------------------
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

variable "flavor_name" {
  description = "Flavor for master and worker"
  type        = string
  default     = "coa.large.v2"
}

variable "keypair_name" {
  description = "Keypair for master and worker"
  type        = string
  default     = "KeyPair"
}
variable "volume_type" {
  type    = string
  default = "Standard_SSD"
}
variable "volume_size" {
  description = "Size (GB) of the master volume and worker volume"
  type        = number
  default     = 50
}

# Availability Zones / IP Pools
variable "availability_zone_bkk" {
  description = "AZ for BKK"
  type        = string
  default     = "NCP-BKK"
}
variable "external_network_name_bkk" {
  description = "Public/external network name for router gateway (e.g. Standard_Public_IP_Pool_BKK)"
  type        = string
  default     = "Standard_Public_IP_Pool_BKK"
}
variable "public_ip_pool_name_bkk" {
  description = "Public IP pool BKK"
  type        = string
  default     = "Standard_Public_IP_Pool_BKK"
}

# --------------------- Argo CD ---------------------
variable "argocd_namespace" {
  description = "Kubernetes namespace to install Argo CD"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Version of the Argo CD Helm chart"
  type        = string
  default     = "9.1.1"
} 