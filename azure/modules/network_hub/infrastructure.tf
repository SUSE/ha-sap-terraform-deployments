data "azurerm_subscription" "current" {
}


data "azurerm_virtual_network" "vnet-hub" {
  count               = local.vnet_create ? 0 : 1
  name                = var.vnet_name
  resource_group_name = local.resource_group_name
}

data "azurerm_subnet" "subnet-hub-gateway" {
  count                = local.subnet_gateway_create ? 0 : 1
  name                 = var.subnet_gateway_name
  virtual_network_name = var.vnet_name
  resource_group_name  = local.resource_group_name
}

data "azurerm_subnet" "subnet-hub-mgmt" {
  count                = local.subnet_mgmt_create ? 0 : 1
  name                 = var.subnet_mgmt_name
  virtual_network_name = var.vnet_name
  resource_group_name  = local.resource_group_name
}

data "azurerm_subnet" "subnet-hub-mon" {
  count                = local.subnet_mon_create ? 0 : 1
  name                 = var.subnet_mon_name
  virtual_network_name = var.vnet_name
  resource_group_name  = local.resource_group_name
}

locals {
  vnet_create = var.vnet_name == "" ? true : false
  vnet_name   = local.vnet_create ? azurerm_virtual_network.vnet-hub.0.name : var.vnet_name
  vnet_id     = local.vnet_create ? azurerm_virtual_network.vnet-hub.0.id : format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/%s", data.azurerm_subscription.current.subscription_id, local.resource_group_name, local.vnet_name)

  vnet_address_range           = local.vnet_create ? azurerm_virtual_network.vnet-hub.0.address_space.0 : data.azurerm_virtual_network.vnet-hub.0.address_space.0
  subnet_gateway_create        = var.subnet_gateway_name == "" ? true : false
  subnet_gateway_name          = local.subnet_gateway_create ? azurerm_subnet.subnet-hub-gateway.0.name : data.azurerm_subnet.subnet-hub-gateway.0.name
  subnet_gateway_id            = local.subnet_gateway_create ? azurerm_subnet.subnet-hub-gateway.0.id : format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/%s/subnets/%s", data.azurerm_subscription.current.subscription_id, local.resource_group_name, local.vnet_name, local.subnet_gateway_name)
  subnet_gateway_address_range = local.subnet_gateway_create ? (var.subnet_gateway_address_range == "" ? cidrsubnet(local.vnet_address_range, 8, 255) : var.subnet_gateway_address_range) : data.azurerm_subnet.subnet-hub-gateway.0.address_prefix
  subnet_mgmt_create           = true
  subnet_mgmt_name             = local.subnet_mgmt_create ? azurerm_subnet.subnet-hub-mgmt.0.name : data.azurerm_subnet.subnet-hub-mgmt.0.name
  subnet_mgmt_id               = local.subnet_mgmt_create ? azurerm_subnet.subnet-hub-mgmt.0.id : format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/%s/subnets/%s", data.azurerm_subscription.current.subscription_id, local.resource_group_name, local.vnet_name, local.subnet_mgmt_name)
  subnet_mgmt_address_range    = local.subnet_mgmt_create ? (var.subnet_mgmt_address_range == "" ? cidrsubnet(local.vnet_address_range, 8, 254) : var.subnet_mgmt_address_range) : data.azurerm_subnet.subnet-hub-mgmt.0.address_prefix
  subnet_mon_create            = true
  subnet_mon_name              = local.subnet_mon_create ? azurerm_subnet.subnet-hub-mon.0.name : data.azurerm_subnet.subnet-hub-mon.0.name
  subnet_mon_id                = local.subnet_mon_create ? azurerm_subnet.subnet-hub-mon.0.id : format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/%s/subnets/%s", data.azurerm_subscription.current.subscription_id, local.resource_group_name, local.vnet_name, local.subnet_mon_name)
  subnet_mon_address_range     = local.subnet_mon_create ? (var.subnet_mon_address_range == "" ? cidrsubnet(local.vnet_address_range, 8, 5) : var.subnet_mon_address_range) : data.azurerm_subnet.subnet-hub-mon.0.address_prefix
  resource_group_name          = var.resource_group_hub_name
}

resource "azurerm_resource_group" "rg-hub" {
  count    = var.resource_group_hub_create ? 1 : 0
  name     = local.resource_group_name
  location = var.az_region
}

resource "azurerm_storage_account" "mytfstorageacc" {
  count                    = var.resource_group_hub_create ? 1 : 0
  name                     = "stdiag${var.deployment_name}hub"
  resource_group_name      = local.resource_group_name
  location                 = var.az_region
  account_replication_type = "LRS"
  account_tier             = "Standard"

  tags = {
    workspace = var.deployment_name
  }
}

# Network resources: Virtual Network, Subnet
resource "azurerm_virtual_network" "vnet-hub" {
  count               = local.vnet_create ? 1 : 0
  name                = "vnet-hub-${var.deployment_name}"
  address_space       = [var.vnet_address_range]
  location            = var.az_region
  resource_group_name = local.resource_group_name

  tags = {
    workspace = var.deployment_name
  }
}

resource "azurerm_subnet" "subnet-hub-gateway" {
  count                = local.subnet_gateway_create ? 1 : 0
  name                 = "GatewaySubnet" # has to be hard-coded to this value
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [local.subnet_gateway_address_range]
}

resource "azurerm_subnet" "subnet-hub-mgmt" {
  count                = local.subnet_mgmt_create ? 1 : 0
  name                 = "snet-hub-mgmt-${var.deployment_name}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [local.subnet_mgmt_address_range]
}

resource "azurerm_subnet" "subnet-hub-mon" {
  count                = local.subnet_mon_create ? 1 : 0
  name                 = "snet-hub-mon-${var.deployment_name}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [local.subnet_mon_address_range]
}

# Virtual Network Gateway
resource "azurerm_public_ip" "hub-vpn-gateway1-pip" {
  name                = "hub-vpn-gateway1-pip"
  location            = var.az_region
  resource_group_name = local.resource_group_name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "hub-vnet-gateway" {
  name                = "hub-vpn-gateway1"
  location            = var.az_region
  resource_group_name = local.resource_group_name

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

