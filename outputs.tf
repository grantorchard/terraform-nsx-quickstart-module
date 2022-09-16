output "public_networks" {
	value = nsxt_policy_segment.public.*.name
}

output "private_networks" {
	value = nsxt_policy_segment.private.*.name
}