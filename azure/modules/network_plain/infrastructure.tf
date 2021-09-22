data "azurerm_subscription" "current" {
}

data "azurerm_virtual_network" "vnet" {
  count               = var.vnet_name != "" && var.vnet_address_range == "" ? 1 : 0
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "snet-workload" {
  count                = var.subnet_name != "" && var.subnet_address_range == "" ? 1 : 0
  name                 = var.subnet_name
  virtual_network_name = local.vnet_name
  resource_group_name  = var.resource_group_name
}

locals {
  # If vnet_name is not defined, a new vnet is created
  # If vnet_name is defined, and the vnet_address_range is empty, it will try to get the ip range from the real vnet using the data source. If vnet_address_range is defined it will use it
  vnet_name           = var.vnet_name == "" ? azurerm_virtual_network.vnet.0.name : var.vnet_name
  subnet_id = var.subnet_name == "" ? azurerm_subnet.snet-workload.0.id : format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/%s/subnets/%s", data.azurerm_subscription.current.subscription_id, var.resource_group_name, var.vnet_name, var.subnet_name)
}

# Network resources: Virtual Network, Subnet

# Plain Network (in case network_topology=plain)

resource "azurerm_virtual_network" "vnet" {
  count               = var.vnet_name == "" ? 1 : 0
  name                = "vnet-${var.deployment_name}"
  address_space       = [var.vnet_address_range]
  location            = var.az_region
  resource_group_name = var.resource_group_name

  tags = {
    workspace = var.deployment_name
  }
}

resource "azurerm_subnet" "snet-workload" {
  count                = var.subnet_name == "" ? 1 : 0
  name                 = "snet-${var.deployment_name}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [var.subnet_address_range]
}

resource "azurerm_subnet_network_security_group_association" "snet-workload" {
  count                = 1
  subnet_id                 = local.subnet_id
  network_security_group_id = azurerm_network_security_group.mysecgroup.0.id
}

resource "azurerm_subnet_route_table_association" "snet-workload" {
  count                = 1
  subnet_id      = local.subnet_id
  route_table_id = azurerm_route_table.myroutes.0.id
}

# Subnet route table

resource "azurerm_route_table" "myroutes" {
  count                = 1
  name                = "route-${var.deployment_name}"
  location            = var.az_region
  resource_group_name = var.resource_group_name

  route {
    name           = "default"
    address_prefix = var.vnet_address_range
    next_hop_type  = "vnetlocal"
  }

  tags = {
    workspace = var.deployment_name
  }
}

# Security group

resource "azurerm_network_security_group" "mysecgroup" {
  count                = 1
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
