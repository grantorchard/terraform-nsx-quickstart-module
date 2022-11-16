locals {
  prefix = var.prefix != "" ? var.prefix : random_pet.this.id
}

resource random_pet "this" {
  length = 2
}
resource "nsxt_policy_dhcp_server" "dhcp_server" {
  #dhcp_enable = var.create_dhcp_server ? length(var.public_networks) : 0
  count             = length(var.public_subnets)
  display_name      = "${local.prefix}-${var.public_subnet_suffix}-${count.index}-dhcp-server"
  description       = "${local.prefix}-${var.public_subnet_suffix}-${count.index} DHCP Server managed via terraform"
  lease_time        = var.dhcp_server_lease
  edge_cluster_path = data.nsxt_policy_edge_cluster.this.path
  server_addresses =  ["${cidrhost(var.public_subnets[count.index], -2)}/${split("/", element(var.public_subnets, count.index))[1]}"]
}

resource "nsxt_policy_dhcp_server" "dhcp_server_private" {
  #dhcp_enable = var.create_dhcp_server ? length(var.public_networks) : 0
  count             = length(var.private_subnets)
  display_name      = "${local.prefix}-${var.private_subnet_suffix}-${count.index}-dhcp-server"
  description       = "${local.prefix}-${var.private_subnet_suffix}-${count.index} DHCP Server managed via terraform"
  lease_time        = var.dhcp_server_lease
  edge_cluster_path = data.nsxt_policy_edge_cluster.this.path
  server_addresses =  ["${cidrhost(var.private_subnets[count.index], -2)}/${split("/", element(var.public_subnets, count.index))[1]}"]
}


resource nsxt_policy_segment "public" {
  count               = length(var.public_subnets)
  display_name        = "${local.prefix}-${var.public_subnet_suffix}-${count.index}"
  description         = var.description
  connectivity_path   = nsxt_policy_tier1_gateway.this.path
  transport_zone_path = data.nsxt_policy_transport_zone.this.path
  #Creates DHCP service for each count if var.create_dhcp_server is true otherwise null.
  dhcp_config_path    = var.create_dhcp_server ? nsxt_policy_dhcp_server.dhcp_server[count.index].path : null
  
  subnet {
    cidr = format("%s%s%s",
      cidrhost(element(var.public_subnets, count.index), 1),
      "/",
      split("/", element(var.public_subnets, count.index))[1]
    )
  dhcp_ranges = var.create_dhcp_server ? ["${cidrhost(var.public_subnets[count.index], 2)}-${cidrhost(var.public_subnets[count.index], -3)}"] : null
   dhcp_v4_config {
      server_address = "${element(nsxt_policy_dhcp_server.dhcp_server[count.index].server_addresses, count.index)}"
      dns_servers = var.dhcp_dns_server
  }
  }
  advanced_config {
    connectivity = "ON"
  }
}

resource nsxt_policy_segment "private" {
  count               = length(var.private_subnets)
  display_name        = "${local.prefix}-${var.private_subnet_suffix}-${count.index}"
  description         = var.description
  connectivity_path   = nsxt_policy_tier1_gateway.this.path
  transport_zone_path = data.nsxt_policy_transport_zone.this.path
  dhcp_config_path    = var.create_dhcp_server ? nsxt_policy_dhcp_server.dhcp_server_private[count.index].path : null
  subnet {
    cidr = format("%s%s%s",
      cidrhost(element(var.private_subnets, count.index), 1),
      "/",
      split("/", element(var.private_subnets, count.index))[1]
    )
    dhcp_ranges = var.create_dhcp_server ? ["${cidrhost(var.private_subnets[count.index], 2)}-${cidrhost(var.private_subnets[count.index], -3)}"] : null
   dhcp_v4_config {
      server_address = "${element(nsxt_policy_dhcp_server.dhcp_server_private[count.index].server_addresses, count.index)}"
      dns_servers = var.dhcp_dns_server
  }
  }
  advanced_config {
    connectivity = "ON"
  }
}

resource nsxt_policy_tier1_gateway "this" {
  description               = var.description
  display_name              = "${local.prefix}-gateway"
  edge_cluster_path         = data.nsxt_policy_edge_cluster.this.path
  failover_mode             = "PREEMPTIVE"
  default_rule_logging      = "false"
  enable_firewall           = "false"
  enable_standby_relocation = "false"
  tier0_path                = data.nsxt_policy_tier0_gateway.this.path
  pool_allocation           = "ROUTING"

  route_advertisement_rule {
    name                      = "rule1"
    action                    = "PERMIT"
    subnets                   = var.public_subnets
    prefix_operator           = "EQ"
    route_advertisement_types = ["TIER1_CONNECTED"]
  }
}

resource nsxt_policy_nat_rule "private" {
  count               = length(var.private_subnets)
  display_name        = "${local.prefix}-${var.private_subnet_suffix}-snat-${count.index}"
  action              = "SNAT"
  translated_networks = [var.private_subnets[count.index]]
  enabled             = var.private_subnets_snat_enabled
  gateway_path        = nsxt_policy_tier1_gateway.this.path
}

resource nsxt_policy_group "private" {
  display_name = "${local.prefix}-${var.private_subnet_suffix}-group"
  description  = var.description

  criteria {
    path_expression {
      member_paths = nsxt_policy_segment.private.*.path
    }
  }
}

resource nsxt_policy_gateway_policy "private" {
  display_name    = "${local.prefix}-${var.private_subnet_suffix}-policy"
  description     = var.description
  category        = "LocalGatewayRules"
  locked          = false
  sequence_number = 3
  stateful        = true
  tcp_strict      = false

  rule {
    display_name       = "default deny inbound"
    destination_groups = [nsxt_policy_group.private.path]
    disabled           = true
    direction          = "IN"
    action             = "DROP"
    logged             = true
    scope              = [nsxt_policy_tier1_gateway.this.path]
  }
}

resource nsxt_policy_lb_service "this" {
  display_name      = "${local.prefix}-lb"
  description       = var.description
  connectivity_path = nsxt_policy_tier1_gateway.this.path
  size              = "SMALL"
  enabled           = true
  error_log_level   = "ERROR"
}