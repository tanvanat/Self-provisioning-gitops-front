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

# provider "haproxy" {
#   url      = "http://haproxy.example.com:8080"
#   username = "username"
#   password = "password"
# }