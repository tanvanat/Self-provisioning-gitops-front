terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 2.0.0"
    }
    haproxy = {
      source  = "SepehrImanian/haproxy"
      version = "0.0.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }
    null = {
      source  = "hashicorp/null"
    }
  }
}

# ใช้ config จาก env / clouds.yaml
provider "openstack" {}

