data "nsxt_policy_transport_zone" "this" {
  display_name = lookup(var.nsx_data[var.environment],"transport_zone_name")
}

data "nsxt_policy_edge_cluster" "this" {
  display_name = lookup(var.nsx_data[var.environment],"edge_cluster_name")
}

data "nsxt_policy_tier0_gateway" "tier0_gw_gateway" {
  display_name = lookup(var.nsx_data[var.environment],"tier0_name")
}
