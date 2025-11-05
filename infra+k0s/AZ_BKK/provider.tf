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

provider "openstack" {
  auth_url             = "https://identity-api.nipa.cloud/v3"
  region               = "NCP-TH"

  user_name            = var.os_username
  password             = var.os_password
  tenant_name         = var.os_project_name
  user_domain_name     = var.os_user_domain
  project_domain_name  = var.os_project_domain

  # to match your CLI --insecure for now
  insecure             = true
}

provider "k0s" {}
