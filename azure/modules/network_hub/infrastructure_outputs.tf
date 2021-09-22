output "vnet_hub_name" {
  value = azurerm_virtual_network.vnet-hub[0].name
}

output "vnet_hub_id" {
  value = azurerm_virtual_network.vnet-hub[0].id
}

output "subnet_hub_gateway_name" {
  value = azurerm_subnet.subnet-hub-gateway[0].name
}

output "subnet_hub_gateway_id" {
  value = azurerm_subnet.subnet-hub-gateway[0].id
}

output "subnet_hub_gateway_address_range" {
  value = local.subnet_gateway_address_range
}

output "subnet_hub_mgmt_name" {
  value = azurerm_subnet.subnet-hub-mgmt[0].name
}

output "subnet_hub_mgmt_id" {
  value = azurerm_subnet.subnet-hub-mgmt[0].id
}

output "subnet_hub_mgmt_address_range" {
  value = local.subnet_mgmt_address_range
}
