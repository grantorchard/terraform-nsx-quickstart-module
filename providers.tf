terraform {
  required_providers {
    nsxt = {
      source = "vmware/nsxt"
      version = "~>3.2"
    }
		random = {
      source = "hashicorp/random"
      version = "~>3"
    }
  }
  provider "nsxt" {
	host = var.nsx_server
}
}