data "azurerm_subscription" "current" {
}

data "azurerm_virtual_network" "vnet" {
  count               = local.vnet_create ? 0 : 1
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "snet-workload" {
  count                = local.subnet_create ? 0 : 1
  name                 = var.subnet_name
  virtual_network_name = local.vnet_name
  resource_group_name  = var.resource_group_name
}

locals {
  # If vnet_name is not defined, a new vnet is created
  # If vnet_name is defined, and the vnet_address_range is empty, it will try to get the ip range from the real vnet using the data source. If vnet_address_range is defined it will use it
  vnet_create                   = var.vnet_name == "" ? true : false
  vnet_name                     = local.vnet_create ? azurerm_virtual_network.vnet.0.name : var.vnet_name
  vnet_address_range            = local.vnet_create ? azurerm_virtual_network.vnet.0.address_space.0 : data.azurerm_virtual_network.vnet.0.address_space.0
  subnet_create                 = var.subnet_name == "" ? true : false
  subnet_id                     = local.subnet_create ? azurerm_subnet.snet-workload.0.id : format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/%s/subnets/%s", data.azurerm_subscription.current.subscription_id, var.resource_group_name, var.vnet_name, var.subnet_name)
  subnet_address_range          = var.subnet_address_range == "" ? cidrsubnet(var.vnet_address_range, 8, 1) : var.subnet_address_range
  shared_storage_anf            = (var.common_variables["hana"]["scale_out_shared_storage_type"] == "anf" || var.common_variables["netweaver"]["shared_storage_type"] == "anf") ? 1 : 0
  subnet_netapp_create          = local.shared_storage_anf == 1 && var.subnet_netapp_name == "" ? true : false
  subnet_netapp_name            = local.subnet_netapp_create ? azurerm_subnet.snet-netapp.0.name : var.subnet_netapp_name
  subnet_netapp_id              = local.shared_storage_anf == 1 && var.subnet_netapp_name == "" ? azurerm_subnet.snet-netapp.0.id : format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/%s/subnets/%s", data.azurerm_subscription.current.subscription_id, var.resource_group_name, local.vnet_name, var.subnet_netapp_name)
  subnet_netapp_address_range   = var.subnet_netapp_name == "" ? (var.subnet_netapp_address_range == "" ? cidrsubnet(local.vnet_address_range, 8, 3) : var.subnet_netapp_address_range) : (var.subnet_netapp_address_range == "" ? data.azurerm_subnet.snet-netapp.0.address_prefix : var.subnet_netapp_address_range)
}

# Network resources: Virtual Network, Subnet

# Plain Network (in case network_topology=plain)

resource "azurerm_virtual_network" "vnet" {
  count               = local.vnet_create ? 1 : 0
  name                = "vnet-${var.deployment_name}"
  address_space       = [var.vnet_address_range]
  location            = var.az_region
  resource_group_name = var.resource_group_name

  tags = {
    workspace = var.deployment_name
  }
}

resource "azurerm_subnet" "snet-workload" {
  count                = local.subnet_create ? 1 : 0
  name                 = "snet-${var.deployment_name}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [local.subnet_address_range]
}

resource "azurerm_subnet_network_security_group_association" "snet-workload" {
  subnet_id                 = local.subnet_id
  network_security_group_id = azurerm_network_security_group.mysecgroup.id
}

resource "azurerm_subnet_route_table_association" "snet-workload" {
  subnet_id      = local.subnet_id
  route_table_id = azurerm_route_table.myroutes.id
}

# Subnet route table

resource "azurerm_route_table" "myroutes" {
  name                = "route-${var.deployment_name}"
  location            = var.az_region
  resource_group_name = var.resource_group_name

  route {
    name           = "default"
    address_prefix = local.vnet_address_range
    next_hop_type  = "vnetlocal"
  }

  tags = {
    workspace = var.deployment_name
  }
}

# Azure Netapp Files resources (see README for ANF setup)
data "azurerm_subnet" "snet-netapp" {
  count                = var.subnet_netapp_name != "" && var.subnet_netapp_address_range == "" ? 1 : 0
  name                 = var.subnet_netapp_name
  virtual_network_name = local.vnet_name
  resource_group_name  = var.resource_group_name
}

resource "azurerm_subnet" "snet-netapp" {

  count                = var.subnet_netapp_name == "" ? local.shared_storage_anf : 0
  name                 = "snet-netapp-${var.deployment_name}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [local.subnet_netapp_address_range]

  delegation {
    name = "netapp"

    service_delegation {
      name    = "Microsoft.Netapp/volumes"
      actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Security group

resource "azurerm_network_security_group" "mysecgroup" {
  name                = "nsg-${var.deployment_name}"
  location            = var.az_region
  resource_group_name = var.resource_group_name
  security_rule {
    name                       = "OUTALL"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "LOCAL"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.vnet_address_range
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HAWK"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "7630"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  // monitoring rules
  security_rule {
    name                       = "nodeExporter"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "9100"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "hanadbExporter"
    priority                   = 1006
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "9668"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "haExporter"
    priority                   = 1007
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "9664"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "SAPHostExporter"
    priority                   = 1008
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "9680"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "prometheus"
    priority                   = 1009
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "9090"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "grafana"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    workspace = var.deployment_name
  }
}
