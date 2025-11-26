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
  }
}