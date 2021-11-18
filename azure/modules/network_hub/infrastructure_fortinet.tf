locals {
  subnet_external_fgt_create = var.fortinet_enabled ? true : false
  subnet_external_fgt_address_range  = (var.subnet_external_fgt_address_range == "" ? cidrsubnet(local.vnet_address_range, 8, 253) : var.subnet_external_fgt_address_range)

  subnet_internal_fgt_create        = var.fortinet_enabled ? true : false
  subnet_internal_fgt_address_range = (var.subnet_internal_fgt_address_range == "" ? cidrsubnet(local.vnet_address_range, 8, 252) : var.subnet_internal_fgt_address_range)

  subnet_hasync_ftnt_create         = var.fortinet_enabled ? true : false
  subnet_hasync_ftnt_address_range = (var.subnet_hasync_ftnt_address_range == "" ? cidrsubnet(local.vnet_address_range, 8, 251) : var.subnet_hasync_ftnt_address_range)

  subnet_mgmt_ftnt_create        = var.fortinet_enabled ? true : false
  subnet_mgmt_ftnt_address_range = (var.subnet_mgmt_ftnt_address_range == "" ? cidrsubnet(local.vnet_address_range, 8, 250) : var.subnet_mgmt_ftnt_address_range)

  subnet_external_fadc_create        = var.fortinet_enabled ? true : false
  subnet_external_fadc_address_range = (var.subnet_external_fadc_address_range == "" ? cidrsubnet(local.vnet_address_range, 8, 249) : var.subnet_external_fadc_address_range)

  subnet_internal_fadc_create        = var.fortinet_enabled ? true : false
  subnet_internal_fadc_address_range = (var.subnet_internal_fadc_address_range == "" ? cidrsubnet(local.vnet_address_range, 8, 248) : var.subnet_internal_fadc_address_range)

}

resource "azurerm_subnet" "subnet-hub-external-fgt" {
  count                = local.subnet_external_fgt_create ? 1 : 0
  name                 = "snet-hub-external-fgt-${var.deployment_name}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [local.subnet_external_fgt_address_range]

  depends_on = [
    azurerm_virtual_network_gateway.hub-vnet-gateway
  ]
}

resource "azurerm_subnet" "subnet-hub-internal-fgt" {
  count                = local.subnet_internal_fgt_create ? 1 : 0
  name                 = "snet-hub-trusted-internal-fgt${var.deployment_name}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [local.subnet_internal_fgt_address_range]

  depends_on = [
    azurerm_virtual_network_gateway.hub-vnet-gateway
  ]
}
resource "azurerm_subnet" "subnet-hub-hasync-ftnt" {
  count                = local.subnet_hasync_ftnt_create ? 1 : 0
  name                 = "snet-hub-hasync-ftnt${var.deployment_name}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [local.subnet_hasync_ftnt_address_range]

  depends_on = [
    azurerm_virtual_network_gateway.hub-vnet-gateway
  ]
}

resource "azurerm_subnet" "subnet-hub-mgmt-ftnt" {
  count                = local.subnet_mgmt_ftnt_create ? 1 : 0
  name                 = "snet-hub-mgmt-ftnt-${var.deployment_name}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [local.subnet_mgmt_ftnt_address_range]

  depends_on = [
    azurerm_virtual_network_gateway.hub-vnet-gateway
  ]
}

resource "azurerm_subnet" "subnet-hub-external-fadc" {
  count                = local.subnet_external_fadc_create ? 1 : 0
  name                 = "snet-hub-external-fadc-${var.deployment_name}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [local.subnet_external_fadc_address_range]

  depends_on = [
    azurerm_virtual_network_gateway.hub-vnet-gateway
  ]
}

resource "azurerm_subnet" "subnet-hub-internal-fadc" {
  count                = local.subnet_internal_fadc_create ? 1 : 0
  name                 = "snet-hub-internal-fadc-${var.deployment_name}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [local.subnet_internal_fadc_address_range]

  depends_on = [
    azurerm_virtual_network_gateway.hub-vnet-gateway
  ]
}

output "subnet-hub-external-fgt" {
  value = azurerm_subnet.subnet-hub-external-fgt
}
output "subnet-hub-external-fgt-address-range" {
  value = local.subnet_external_fgt_address_range
}

output "subnet-hub-internal-fgt" {
  value = azurerm_subnet.subnet-hub-internal-fgt
}
output "subnet-hub-internal-fgt-address-range" {
  value = local.subnet_internal_fgt_address_range
}

output "subnet-hub-hasync-ftnt" {
  value = azurerm_subnet.subnet-hub-hasync-ftnt
}
output "subnet-hub-hasync-ftnt-address-range" {
  value = local.subnet_hasync_ftnt_address_range
}

output "subnet-hub-mgmt-ftnt" {
  value = azurerm_subnet.subnet-hub-mgmt-ftnt
}
output "subnet-hub-mgmt-ftnt-address-range" {
  value = local.subnet_mgmt_ftnt_address_range
}

output "subnet-hub-external-fadc" {
  value = azurerm_subnet.subnet-hub-external-fadc
}
output "subnet-hub-external-fadc-address-range" {
  value = local.subnet_external_fadc_address_range
}

output "subnet-hub-internal-fadc" {
  value = azurerm_subnet.subnet-hub-internal-fadc
}
output "subnet-hub-internal-fadc-address-range" {
  value = local.subnet_internal_fadc_address_range
}
