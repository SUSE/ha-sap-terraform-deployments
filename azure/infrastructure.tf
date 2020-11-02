# Configure the Azure Provider
provider "azurerm" {
  version = "~> 2.32.0"
  features {}
}

terraform {
  required_version = ">= 0.13"
}

data "azurerm_subscription" "current" {
}

data "azurerm_virtual_network" "mynet" {
  count               = var.vnet_name != "" && var.vnet_address_range == "" ? 1 : 0
  name                = var.vnet_name
  resource_group_name = local.resource_group_name
}

data "azurerm_subnet" "mysubnet" {
  count                = var.subnet_name != "" && var.subnet_address_range == "" ? 1 : 0
  name                 = var.subnet_name
  virtual_network_name = local.vnet_name
  resource_group_name  = local.resource_group_name
}

locals {
  deployment_name = var.deployment_name != "" ? var.deployment_name : terraform.workspace

  resource_group_name = var.resource_group_name == "" ? azurerm_resource_group.myrg.0.name : var.resource_group_name
  vnet_name           = var.vnet_name == "" ? azurerm_virtual_network.mynet.0.name : var.vnet_name
  subnet_id = var.subnet_name == "" ? azurerm_subnet.mysubnet.0.id : format(
  "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/%s/subnets/%s", data.azurerm_subscription.current.subscription_id, var.resource_group_name, var.vnet_name, var.subnet_name)
  # If vnet_name is not defined, a new vnet is created
  # If vnet_name is defined, and the vnet_address_range is empty, it will try to get the ip range from the real vnet using the data source. If vnet_address_range is defined it will use it
  vnet_address_range   = var.vnet_name == "" ? var.vnet_address_range : (var.vnet_address_range == "" ? data.azurerm_virtual_network.mynet.0.address_space.0 : var.vnet_address_range)
  subnet_address_range = var.subnet_name == "" ? (var.subnet_address_range == "" ? cidrsubnet(local.vnet_address_range, 8, 1) : var.subnet_address_range) : (var.subnet_address_range == "" ? data.azurerm_subnet.mysubnet.0.address_prefix : var.subnet_address_range)
}

# Azure resource group and storage account resources
resource "azurerm_resource_group" "myrg" {
  count    = var.resource_group_name == "" ? 1 : 0
  name     = "rg-ha-sap-${local.deployment_name}"
  location = var.az_region
}

resource "azurerm_storage_account" "mytfstorageacc" {
  name                     = "stdiag${lower(local.deployment_name)}"
  resource_group_name      = local.resource_group_name
  location                 = var.az_region
  account_replication_type = "LRS"
  account_tier             = "Standard"

  tags = {
    workspace = local.deployment_name
  }
}

# Network resources: Virtual Network, Subnet
resource "azurerm_virtual_network" "mynet" {
  count               = var.vnet_name == "" ? 1 : 0
  name                = "vnet-${lower(local.deployment_name)}"
  address_space       = [local.vnet_address_range]
  location            = var.az_region
  resource_group_name = local.resource_group_name

  tags = {
    workspace = local.deployment_name
  }
}

resource "azurerm_subnet" "mysubnet" {
  count                = var.subnet_name == "" ? 1 : 0
  name                 = "snet-${lower(local.deployment_name)}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [local.subnet_address_range]
}

resource "azurerm_subnet_network_security_group_association" "mysubnet" {
  subnet_id                 = local.subnet_id
  network_security_group_id = azurerm_network_security_group.mysecgroup.id
}

resource "azurerm_subnet_route_table_association" "mysubnet" {
  subnet_id      = local.subnet_id
  route_table_id = azurerm_route_table.myroutes.id
}

# Subnet route table

resource "azurerm_route_table" "myroutes" {
  name                = "route-${lower(local.deployment_name)}"
  location            = var.az_region
  resource_group_name = local.resource_group_name

  route {
    name           = "default"
    address_prefix = local.vnet_address_range
    next_hop_type  = "vnetlocal"
  }

  tags = {
    workspace = local.deployment_name
  }
}

# Security group

resource "azurerm_network_security_group" "mysecgroup" {
  name                = "nsg-${lower(local.deployment_name)}"
  location            = var.az_region
  resource_group_name = local.resource_group_name
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
    source_address_prefix      = local.vnet_address_range
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
    name                       = "prometheus"
    priority                   = 1008
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
    priority                   = 1009
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    workspace = local.deployment_name
  }
}

# Bastion

module "bastion" {
  source              = "./modules/bastion"
  common_variables    = module.common_variables.configuration
  az_region           = var.az_region
  os_image            = local.bastion_os_image
  vm_size             = "Standard_B1s"
  resource_group_name = local.resource_group_name
  vnet_name           = local.vnet_name
  storage_account     = azurerm_storage_account.mytfstorageacc.primary_blob_endpoint
  snet_address_range  = cidrsubnet(local.vnet_address_range, 8, 2)
}
