variable prefix {
  description = "Naming prefix to be used on all provisioned resources"
  type        = string
  default     = ""
}
variable description {
  description = "A description to place on all objects that support it"
  type        = string
  default     = "Provisioned by Terraform, do not manage via UI."
}

variable environment {
  description = "The environment type that you are creating"
  type        = string
  default     = "production"
}

variable "dhcp_server_lease" {
  description = "DHCP Default Server Lease"
  type = string
  default = "86400"
}
variable "dhcp_dns_server" {
  description = "DHCP Default DNS server"
  type = list(string)
  default = ["1.1.1.1","8.8.8.8"]
}
variable "create_dhcp_server" {
  type        = bool
  description = "(Optional) Conditional that creates a DHCP server within the NSX-T environment on the Tier1 Router"
  default     = false
}


variable public_subnet_suffix {
  description = "Suffix to append to public subnet names"
  type        = string
  default     = "public"
}

variable private_subnet_suffix {
  description = "Suffix to append to private subnet names"
  type        = string
  default     = "private"
}

variable public_subnets {
  description = "A list of public subnets to use"
  type        = list(string)
  default     = ["10.0.0.0/28","10.0.0.16/28","10.0.0.32/28"]
}

variable private_subnets {
  description = "A list of private subnets to use"
  type        = list(string)
  default     = []
}

variable connectivity {
  description = "Toggles connectivity of the Tier1 gateway. Supports ON or OFF"
  type        = string
  default     = "ON"
}

variable private_subnets_snat_enabled {
  description = "Toggles the SNAT rules for the private segments"
  type        = bool
  default     = true
}


variable nsx_data {
	type = map(map(string))
	default = {
		"production" = {
			"transport_zone_name" = "TZ-OVERLAY"
			"edge_cluster_name" = "edge-cluster"
			"tier0_name" = "Provider-LR"
		}
	}
}