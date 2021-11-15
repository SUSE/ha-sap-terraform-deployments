locals {
  subnet_dmz_create        = var.fortinet_enabled ? true : false
  subnet_dmz_address_range = (var.subnet_dmz_address_range == "" ? cidrsubnet(local.vnet_address_range, 8, 253) : var.subnet_dmz_address_range)

  subnet_trusted_create        = var.fortinet_enabled ? true : false
  subnet_trusted_address_range = (var.subnet_trusted_address_range == "" ? cidrsubnet(local.vnet_address_range, 8, 252) : var.subnet_trusted_address_range)

  subnet_hasync_create        = var.fortinet_enabled ? true : false
  subnet_hasync_address_range = (var.subnet_hasync_address_range == "" ? cidrsubnet(local.vnet_address_range, 8, 251) : var.subnet_hasync_address_range)

  subnet_fortinet_mgmt_create        = var.fortinet_enabled ? true : false
  subnet_fortinet_mgmt_address_range = (var.subnet_fortinet_mgmt_address_range == "" ? cidrsubnet(local.vnet_address_range, 8, 250) : var.subnet_fortinet_mgmt_address_range)

  subnet_shared_services_create        = var.fortinet_enabled ? true : false
  subnet_shared_services_address_range = (var.subnet_shared_services_address_range == "" ? cidrsubnet(local.vnet_address_range, 8, 249) : var.subnet_shared_services_address_range)

  subnet_waf_create        = var.fortinet_enabled ? true : false
  subnet_waf_address_range = (var.subnet_waf_address_range == "" ? cidrsubnet(local.vnet_address_range, 8, 248) : var.subnet_waf_address_range)

}

resource "azurerm_subnet" "subnet-hub-dmz" {
  count                = local.subnet_dmz_create ? 1 : 0
  name                 = "snet-hub-dmz-${var.deployment_name}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [local.subnet_dmz_address_range]
}

resource "azurerm_subnet" "subnet-hub-trusted" {
  count                = local.subnet_trusted_create ? 1 : 0
  name                 = "snet-hub-trusted-${var.deployment_name}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [local.subnet_trusted_address_range]
}
resource "azurerm_subnet" "subnet-hub-hasync" {
  count                = local.subnet_hasync_create ? 1 : 0
  name                 = "snet-hub-hasync-${var.deployment_name}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [local.subnet_hasync_address_range]
}

resource "azurerm_subnet" "subnet-hub-fortinet-mgmt" {
  count                = local.subnet_fortinet_mgmt_create ? 1 : 0
  name                 = "snet-hub-fortinet-mgmt-${var.deployment_name}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [local.subnet_fortinet_mgmt_address_range]
}

resource "azurerm_subnet" "subnet-hub-shared-services" {
  count                = local.subnet_shared_services_create ? 1 : 0
  name                 = "snet-hub-shared-services-${var.deployment_name}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [local.subnet_shared_services_address_range]
}

resource "azurerm_subnet" "subnet-hub-waf" {
  count                = local.subnet_waf_create ? 1 : 0
  name                 = "snet-hub-waf-${var.deployment_name}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [local.subnet_waf_address_range]
}

output "subnet-hub-dmz" {
  value = azurerm_subnet.subnet-hub-dmz
}
output "subnet-hub-dmz-address-range" {
  value = local.subnet_dmz_address_range
}

output "subnet-hub-trusted" {
  value = azurerm_subnet.subnet-hub-trusted
}
output "subnet-hub-trusted-address-range" {
  value = local.subnet_trusted_address_range
}

output "subnet-hub-hasync" {
  value = azurerm_subnet.subnet-hub-hasync
}
output "subnet-hub-hasync-address-range" {
  value = local.subnet_hasync_address_range
}

output "subnet-hub-fortinet-mgmt" {
  value = azurerm_subnet.subnet-hub-fortinet-mgmt
}
output "subnet-hub-fortinet-mgmt-address-range" {
  value = local.subnet_fortinet_mgmt_address_range
}

output "subnet-hub-shared-services" {
  value = azurerm_subnet.subnet-hub-shared-services
}
output "subnet-hub-shared-services-address-range" {
  value = local.subnet_shared_services_address_range
}

output "subnet-hub-waf" {
  value = azurerm_subnet.subnet-hub-waf
}
output "subnet-hub-waf-address-range" {
  value = local.subnet_waf_address_range
}
