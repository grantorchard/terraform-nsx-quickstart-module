output "public_networks" {
	value = nsxt_policy_segment.public.*.display_name
}

output "private_networks" {
	value = nsxt_policy_segment.private.*.display_name
}