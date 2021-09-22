output "vnet_spoke_name" {
  value = azurerm_virtual_network.vnet-spoke[0].name
}

output "vnet_spoke_id" {
  value = azurerm_virtual_network.vnet-spoke[0].id
}

# output "subnet_spoke_mgmt_name" {
#   value = azurerm_subnet.subnet-spoke-mgmt[0].name
# }
# 
# output "subnet_spoke_mgmt_id" {
#   value = azurerm_subnet.subnet-spoke-mgmt[0].id
# }

output "subnet_spoke_workload_name" {
  value = azurerm_subnet.subnet-spoke-workload[0].name
}

output "subnet_spoke_workload_id" {
  value = azurerm_subnet.subnet-spoke-workload[0].id
}
