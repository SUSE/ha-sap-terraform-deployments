data "azurerm_subscription" "current" {
}


data "azurerm_virtual_network" "vnet-hub" {
  count               = var.vnet_name != "" ? 1 : 0
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}
 
data "azurerm_subnet" "subnet-hub-gateway" {
  count                = var.subnet_gateway_name != "" && var.subnet_gateway_address_range == "" ? 1 : 0
  name                 = var.subnet_gateway_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

data "azurerm_subnet" "subnet-hub-mgmt" {
  count                = var.subnet_mgmt_name != "" && var.subnet_mgmt_address_range == "" ? 1 : 0
  name                 = var.subnet_mgmt_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

locals {
  vnet_name         = var.vnet_name == "" ? azurerm_virtual_network.vnet-hub.0.name : var.vnet_name
  vnet_address_range           = var.vnet_name == "" ? var.vnet_address_range : (var.vnet_address_range == "" ? data.azurerm_virtual_network.vnet-hub.0.address_space.0 : var.vnet_address_range)
  subnet_gateway_address_range = var.subnet_gateway_name == "" ? (var.subnet_gateway_address_range == "" ? cidrsubnet(local.vnet_address_range, 8, 255) : var.subnet_gateway_address_range) : (var.subnet_gateway_address_range == "" ? data.azurerm_subnet.subnet-hub-gateway.0.address_prefix : var.subnet_gateway_address_range)
  subnet_mgmt_address_range    = var.subnet_mgmt_name == "" ? (var.subnet_mgmt_address_range == "" ? cidrsubnet(local.vnet_address_range, 8, 254) : var.subnet_mgmt_address_range) : (var.subnet_mgmt_address_range == "" ? data.azurerm_subnet.subnet-hub-mgmt.0.address_prefix : var.subnet_mgmt_address_range)
}

# Network resources: Virtual Network, Subnet
resource "azurerm_virtual_network" "vnet-hub" {
  count               = var.vnet_name == "" ? 1 : 0
  name                = "vnet-hub-${var.deployment_name}" 
  address_space       = [var.vnet_address_range]
  location            = var.az_region
  resource_group_name = var.resource_group_name

  tags = {
    workspace = var.deployment_name
  }
}

resource "azurerm_subnet" "subnet-hub-gateway" {
  count                = var.subnet_gateway_name == "" ? 1 : 0
  name                 = "GatewaySubnet" # has to be hard-coded to this value
  resource_group_name  = var.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [local.subnet_gateway_address_range]
}

resource "azurerm_subnet" "subnet-hub-mgmt" {
  count                = var.subnet_mgmt_name == "" ? 1 : 0
  name                 = "snet-hub-mgmt-${var.deployment_name}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [local.subnet_mgmt_address_range]
}

# Virtual Network Gateway
resource "azurerm_public_ip" "hub-vpn-gateway1-pip" {
    name                = "hub-vpn-gateway1-pip"
    location            = var.az_region
    resource_group_name = var.resource_group_name

    allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "hub-vnet-gateway" {
    name                = "hub-vpn-gateway1"
    location            = var.az_region
    resource_group_name = var.resource_group_name

    type     = "Vpn"
    vpn_type = "RouteBased"

    active_active = false
    enable_bgp    = false
    sku           = "VpnGw1"

    ip_configuration {
      name                          = "vnetGatewayConfig"
      public_ip_address_id          = azurerm_public_ip.hub-vpn-gateway1-pip.id
      private_ip_address_allocation = "Dynamic"
      subnet_id                     = azurerm_subnet.subnet-hub-gateway.0.id
    }
    depends_on = [azurerm_public_ip.hub-vpn-gateway1-pip]
}

