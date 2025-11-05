# SSH
variable "ssh_user" {
    description = "Default SSH user for Ubuntu cloud images"
    type        = string
    default     = "ubuntu"
}

variable "private_key_path" {
    description = "Path to your private SSH key"
    type        = string
    default     = "~/.ssh/id_rsa"
}

# --------------------- Set up instance ---------------------
# Image / Flavors / Keypair / Volumes
variable "image_id" {
    description = "Image ID for boot volume"
    type        = string
    default     = "30c876dd-4470-47d8-b13a-df5f18c85ba4"
}

variable "image_name" {
    description = "Image name for boot volume"
    type        = string
    default     = "ubuntu-20-v220723"
}

variable "flavor_name" {
    description = "Flavor for master and worker"
    type        = string
    default     = "csa.xlarge.v2"
    }

variable "keypair_name" {
    description = "Keypair for master and worker"
    type        = string
    default     = "keypair"
}

variable "volume_size" {
    description = "Size (GB) of the master volume and worker volume"
    type        = number
    default     = 50
}

# Availability Zones / IP Pools
variable "availability_zone_non" {
    description = "AZ for NON"
    type        = string
    default     = "NCP-NON"
}

variable "public_ip_pool_name_non" {
    description = "Public IP pool NON"
    type        = string
    default     = "Standard_Public_IP_Pool_NON"
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
    default     = "9.0.5"
} 