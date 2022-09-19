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
  default     = []
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