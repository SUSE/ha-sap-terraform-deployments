output "vnet_spoke_name" {
  value = local.vnet_name
}

# output "subnet_spoke_mgmt_name" {
#   value = local.subnet_workload_name
# }
# 
# output "subnet_spoke_mgmt_id" {
#   value = local.subnet_mgmt_id
# }
#
# output "subnet_spoke_mgmt_address_range" {
#   value = local.subnet_mgmt_address_range
# }

output "subnet_spoke_workload_name" {
  value = local.subnet_workload_name
}

output "subnet_spoke_workload_id" {
  value = local.subnet_workload_id
}

output "subnet_spoke_workload_address_range" {
  value = local.subnet_workload_address_range
}
