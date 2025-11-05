terraform {
    required_providers {
        openstack = {
            source  = "terraform-provider-openstack/openstack"
            version = "~> 3.0.0"
        }
        kubernetes = { 
            source = "hashicorp/kubernetes", 
            version = "~> 2.30" 
        }
        helm = { 
            source = "hashicorp/helm",       
            version = "~> 3.0" 
        }
        k0s = {
            source  = "bosmak/k0s"
            version = "~> 0.6"
        }
        time = { 
            source = "hashicorp/time",       
            version = "~> 0.11" 
        }
    }
}

provider "openstack" {
    user_name           = "tanvanat@nipa.cloud"
    tenant_name         = "Terraform-test"
    domain_name         = "nipacloud"
    password            = "Front1234460!"
    auth_url            = "https://stg.thaiopenstack.com:5000"
    region              = "NCP-TH"
}

provider "k0s" {}

provider "kubernetes" {
  config_path = "${path.module}/config/kubeconfig.yaml"
}

provider "helm" {
  kubernetes = {
    config_path = "${path.module}/config/kubeconfig.yaml"
  }
}