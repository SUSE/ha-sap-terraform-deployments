data "azurerm_subscription" "current" {
}

data "azurerm_virtual_network" "vnet-spoke" {
  count               = var.vnet_name != "" ? 1 : 0
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}
 
# data "azurerm_subnet" "subnet-spoke-mgmt" {
#   count               = var.subnet_mgmt_name != "" ? 1 : 0
#   name                 = var.subnet_mgmt_name
#   virtual_network_name = local.vnet_name
#   resource_group_name  = var.resource_group_name
# }

data "azurerm_subnet" "subnet-spoke-workload" {
  count               = var.subnet_workload_name != "" ? 1 : 0
  name                 = var.subnet_workload_name
  virtual_network_name = local.vnet_name
  resource_group_name  = var.resource_group_name
}

locals {
  vnet_hub_id           = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/%s", data.azurerm_subscription.current.subscription_id, var.resource_group_name, var.vnet_hub_name)
  vnet_name         = var.vnet_name == "" ? azurerm_virtual_network.vnet-spoke.0.name : var.vnet_name
  # subnet_mgmt_name         = var.subnet_mgmt_name == "" ? azurerm_subnet.subnet-spoke-mgmt.0.name : var.vnet_name
  # subnet_mgmt_id    = var.subnet_mgmt_name == "" ? azurerm_subnet.subnet-spoke-mgmt.0.id : format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/%s/subnets/%s", data.azurerm_subscription.current.subscription_id, var.resource_group_name, var.vnet_name, var.subnet_mgmt_name)
  subnet_workload_name         = var.subnet_workload_name == "" ? azurerm_subnet.subnet-spoke-workload.0.name : var.vnet_name
  subnet_workload_id    = var.subnet_workload_name == "" ? azurerm_subnet.subnet-spoke-workload.0.id : format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/%s/subnets/%s", data.azurerm_subscription.current.subscription_id, var.resource_group_name, var.vnet_name, var.subnet_workload_name)
}

# Network resources: Virtual Network, Subnet
resource "azurerm_virtual_network" "vnet-spoke" {
  count               = var.vnet_name == "" ? 1 : 0
  name                = "vnet-spoke-${var.spoke_name}-${var.deployment_name}" 
  address_space       = [var.vnet_address_range]
  location            = var.az_region
  resource_group_name = var.resource_group_name

  tags = {
    workspace = var.deployment_name
  }
}

# resource "azurerm_subnet" "subnet-spoke-mgmt" {
#   count                = var.subnet_mgmt_name == "" ? 1 : 0
#   name                 = "snet-spoke-${var.spoke_name}-mgmt-${var.deployment_name}"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = local.vnet_name
#   address_prefixes     = [var.subnet_mgmt_address_range]
# }

resource "azurerm_subnet" "subnet-spoke-workload" {
  count                = var.subnet_workload_name == "" ? 1 : 0
  name                 = "snet-spoke-${var.spoke_name}-workload-${var.deployment_name}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [var.subnet_workload_address_range]
}

resource "azurerm_virtual_network_peering" "peer-spoke1-hub" {
    count                     = 1
    name                      = "peer-spoke-${var.spoke_name}-hub-${var.deployment_name}"
    resource_group_name       = var.resource_group_name
    virtual_network_name      = local.vnet_name
    remote_virtual_network_id = local.vnet_hub_id

    allow_virtual_network_access = true
    allow_forwarded_traffic = true
    allow_gateway_transit   = false
    use_remote_gateways     = true
}

resource "azurerm_virtual_network_peering" "peer-hub-spoke1" {
    count                     = 1
    name                      = "peer-hub-spoke-${var.spoke_name}-${var.deployment_name}"
    resource_group_name       = var.resource_group_name
    virtual_network_name      = var.vnet_hub_name
    remote_virtual_network_id = azurerm_virtual_network.vnet-spoke.0.id
    allow_virtual_network_access = true
    allow_forwarded_traffic   = true
    allow_gateway_transit     = true
    use_remote_gateways       = false
}
