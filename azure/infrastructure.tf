# Configure the Azure Provider
provider "azurerm" {
  version = "<= 1.33"
}

provider "template" {
  version = "~> 2.1"
}

terraform {
  required_version = ">= 0.12"
}

# Azure resource group and storage account resources
resource "azurerm_resource_group" "myrg" {
  name     = "rg-ha-sap-${terraform.workspace}"
  location = var.az_region
}

resource "azurerm_storage_account" "mytfstorageacc" {
  name                     = "stdiag${lower(terraform.workspace)}"
  resource_group_name      = azurerm_resource_group.myrg.name
  location                 = var.az_region
  account_replication_type = "LRS"
  account_tier             = "Standard"

  tags = {
    workspace = terraform.workspace
  }
}

# Network resources: Virtual Network, Subnet
resource "azurerm_virtual_network" "mynet" {
  name                = "vnet-${lower(terraform.workspace)}"
  address_space       = ["10.74.0.0/16"]
  location            = var.az_region
  resource_group_name = azurerm_resource_group.myrg.name

  tags = {
    workspace = terraform.workspace
  }
}

resource "azurerm_subnet" "mysubnet" {
  name                 = "snet-default"
  resource_group_name  = azurerm_resource_group.myrg.name
  virtual_network_name = azurerm_virtual_network.mynet.name
  address_prefix       = "10.74.1.0/24"
}

resource "azurerm_subnet_network_security_group_association" "mysubnet" {
  subnet_id                 = azurerm_subnet.mysubnet.id
  network_security_group_id = azurerm_network_security_group.mysecgroup.id
}

resource "azurerm_subnet_route_table_association" "mysubnet" {
  subnet_id      = azurerm_subnet.mysubnet.id
  route_table_id = azurerm_route_table.myroutes.id
}

# Subnet route table

resource "azurerm_route_table" "myroutes" {
  name                = "route-${lower(terraform.workspace)}"
  location            = var.az_region
  resource_group_name = azurerm_resource_group.myrg.name

  route {
    name           = "default"
    address_prefix = "10.74.0.0/16"
    next_hop_type  = "vnetlocal"
  }

  tags = {
    workspace = terraform.workspace
  }
}

# Security group

resource "azurerm_network_security_group" "mysecgroup" {
  name                = "nsg-${lower(terraform.workspace)}"
  location            = var.az_region
  resource_group_name = azurerm_resource_group.myrg.name
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
    source_address_prefix      = "10.74.0.0/16"
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


  tags = {
    workspace = terraform.workspace
  }
}
