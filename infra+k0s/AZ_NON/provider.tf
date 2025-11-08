terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 2.0.0"
    }
    k0s = {
      source  = "bosmak/k0s"
      version = "~> 0.6"
    }
  }
}

provider "openstack" {}

provider "k0s" {}