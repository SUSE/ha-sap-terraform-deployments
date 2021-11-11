output "rg_hub_name" {
  value = local.resource_group_name
}

output "rg_hub_primary_blob_endpoint" {
  value = var.resource_group_hub_create ? azurerm_storage_account.mytfstorageacc[0].primary_blob_endpoint : ""
}

output "vnet_hub_name" {
  value = local.vnet_name
}

output "vnet_hub_id" {
  value = local.vnet_id
}

output "vnet_hub_address_range" {
  value = local.vnet_address_range
}

output "subnet_hub_gateway_name" {
  value = local.subnet_gateway_name
}

output "subnet_hub_gateway_id" {
  value = local.subnet_gateway_id
}

output "subnet_hub_gateway_address_range" {
  value = local.subnet_gateway_address_range
}

output "subnet_hub_mgmt_name" {
  value = local.subnet_mgmt_name
}

output "subnet_hub_mgmt_id" {
  value = local.subnet_mgmt_id
}

output "subnet_hub_mgmt_address_range" {
  value = local.subnet_mgmt_address_range
}

output "subnet_hub_mon_name" {
  value = local.subnet_mon_name
}

output "subnet_hub_mon_id" {
  value = local.subnet_mon_id
}

output "subnet_hub_mon_address_range" {
  value = local.subnet_mon_address_range
}

output "subnet_hub_vnet_gateway" {
  value = azurerm_virtual_network_gateway.hub-vnet-gateway
}
