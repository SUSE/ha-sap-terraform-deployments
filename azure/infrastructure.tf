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

locals {
  deployment_name = var.deployment_name != "" ? var.deployment_name : terraform.workspace

  resource_group_name = var.resource_group_name == "" ? azurerm_resource_group.myrg.0.name : var.resource_group_name
  # If vnet_name is not defined, a new vnet is created
  # If vnet_name is defined, and the vnet_address_range is empty, it will try to get the ip range from the real vnet using the data source. If vnet_address_range is defined it will use it

  vnet_name        = var.vnet_name == "" ? (var.network_topology == "hub_spoke" ? module.network_spoke.0.vnet_spoke_name : (var.network_topology == "plain" ? module.network_plain.0.vnet_plain_name : "")) : var.vnet_name
  subnet_id        = var.network_topology == "hub_spoke" ? module.network_spoke.0.subnet_spoke_workload_id : (var.network_topology == "plain" ? module.network_plain.0.subnet_plain_workload_id : "")
  subnet_netapp_id = var.network_topology == "hub_spoke" ? module.network_spoke.0.subnet_spoke_netapp_id : (var.network_topology == "plain" ? module.network_plain.0.subnet_plain_netapp_id : "")

  # used to generate networks
  vnet_address_range = var.vnet_address_range == "" ? (var.network_topology == "hub_spoke" ? module.network_hub.0.vnet_hub_address_range : (var.network_topology == "plain" ? module.network_plain.0.vnet_plain_address_range : "")) : var.vnet_address_range
  # used to generate hosts
  subnet_address_range            = var.subnet_address_range == "" ? (var.network_topology == "hub_spoke" ? module.network_spoke.0.subnet_spoke_workload_address_range : (var.network_topology == "plain" ? module.network_plain.0.subnet_plain_workload_address_range : "")) : var.subnet_address_range
  subnet_bastion_id               = var.network_topology == "hub_spoke" && var.vnet_hub_create ? module.network_hub.0.subnet_hub_mgmt_id : (var.network_topology == "plain" ? module.bastion.0.subnet_bastion_id : "")
  subnet_bastion_address_range    = var.network_topology == "hub_spoke" && var.vnet_hub_create ? module.network_hub.0.subnet_hub_mgmt_address_range : cidrsubnet(local.vnet_address_range, 8, 2)
  subnet_monitoring_id            = var.network_topology == "hub_spoke" && var.vnet_hub_create ? module.network_hub.0.subnet_hub_mon_id : (var.network_topology == "plain" ? module.network_plain.0.subnet_plain_workload_id : "")
  subnet_monitoring_address_range = var.network_topology == "hub_spoke" && var.vnet_hub_create ? module.network_hub.0.subnet_hub_mon_address_range : local.subnet_address_range

  shared_storage_anf = (var.hana_scale_out_shared_storage_type == "anf" || var.netweaver_shared_storage_type == "anf") ? 1 : 0
  anf_account_name   = local.shared_storage_anf == 1 ? (var.anf_account_name == "" ? azurerm_netapp_account.mynetapp-acc.0.name : var.anf_account_name) : ""
  anf_pool_name      = local.shared_storage_anf == 1 ? (var.anf_pool_name == "" ? azurerm_netapp_pool.mynetapp-pool.0.name : var.anf_pool_name) : ""
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

# Plain Network (in case network_topology=plain)

module "network_plain" {
  count                       = var.network_topology == "plain" ? 1 : 0
  source                      = "./modules/network_plain"
  common_variables            = module.common_variables.configuration
  deployment_name             = lower(local.deployment_name)
  az_region                   = var.az_region
  resource_group_name         = local.resource_group_name
  vnet_name                   = var.vnet_name
  vnet_address_range          = var.vnet_address_range
  subnet_name                 = var.subnet_name
  subnet_address_range        = var.subnet_address_range
  subnet_netapp_name          = var.subnet_netapp_name
  subnet_netapp_address_range = var.subnet_netapp_address_range
  anf_account_name            = local.anf_account_name
  anf_pool_name               = local.anf_pool_name
}

# Hub Network (in case network_topology=hub_spoke && vnet_hub_create=true)

module "network_hub" {
  count                        = var.network_topology == "hub_spoke" && var.vnet_hub_create ? 1 : 0
  source                       = "./modules/network_hub"
  common_variables             = module.common_variables.configuration
  deployment_name              = lower(local.deployment_name)
  az_region                    = var.az_region
  resource_group_name          = local.resource_group_name
  resource_group_hub_create    = var.resource_group_hub_create
  resource_group_hub_name      = var.resource_group_hub_name == "" ? (var.resource_group_hub_create ? format("%s-hub", local.resource_group_name) : local.resource_group_name) : var.resource_group_hub_name
  vnet_name                    = var.vnet_hub_name
  vnet_address_range           = var.vnet_hub_address_range
  subnet_gateway_name          = var.subnet_hub_gateway_name
  subnet_gateway_address_range = var.subnet_hub_gateway_address_range
  subnet_mgmt_name             = var.subnet_hub_mgmt_name
  subnet_mgmt_address_range    = var.subnet_hub_mgmt_address_range
  subnet_mon_name              = var.subnet_hub_mon_name
  subnet_mon_address_range     = var.subnet_hub_mon_address_range

  fortinet_enabled = var.fortinet_enabled
}

# Spoke Network (in case network_topology=hub_spoke)

module "network_spoke" {
  count                         = var.network_topology == "hub_spoke" ? 1 : 0
  source                        = "./modules/network_spoke"
  common_variables              = module.common_variables.configuration
  deployment_name               = lower(local.deployment_name)
  az_region                     = var.az_region
  resource_group_name           = local.resource_group_name
  resource_group_hub_name       = var.resource_group_hub_name == "" ? (var.resource_group_hub_create ? format("%s-hub", local.resource_group_name) : local.resource_group_name) : var.resource_group_hub_name
  vnet_hub_name                 = var.vnet_hub_create ? module.network_hub.0.vnet_hub_name : var.vnet_hub_name
  spoke_name                    = var.spoke_name
  vnet_address_range            = var.vnet_address_range
  subnet_workload_name          = var.subnet_workload_name
  subnet_workload_address_range = var.subnet_workload_address_range
  subnet_netapp_name            = var.subnet_netapp_name
  subnet_netapp_address_range   = var.subnet_netapp_address_range
  anf_account_name              = local.anf_account_name
  anf_pool_name                 = local.anf_pool_name
  depends_on                    = [module.network_hub.0.subnet_hub_vnet_gateway]
}

# Azure Netapp Files resources (see README for ANF setup)

resource "azurerm_netapp_account" "mynetapp-acc" {
  count               = local.shared_storage_anf
  name                = "netapp-acc-${lower(local.deployment_name)}"
  resource_group_name = local.resource_group_name
  location            = var.az_region
}

resource "azurerm_netapp_pool" "mynetapp-pool" {
  count               = local.shared_storage_anf
  name                = "netapp-pool-${lower(local.deployment_name)}"
  account_name        = local.anf_account_name
  location            = var.az_region
  resource_group_name = local.resource_group_name
  service_level       = var.anf_pool_service_level
  size_in_tb          = var.anf_pool_size
}

# Bastion

module "bastion" {
  count               = var.bastion_enabled ? 1 : 0
  source              = "./modules/bastion"
  network_topology    = var.network_topology
  common_variables    = module.common_variables.configuration
  name                = var.bastion_name
  network_domain      = var.bastion_network_domain == "" ? var.network_domain : var.bastion_network_domain
  az_region           = var.az_region
  os_image            = local.bastion_os_image
  vm_size             = "Standard_B1s"
  resource_group_name = var.resource_group_hub_name == "" ? (var.resource_group_hub_create ? format("%s-hub", local.resource_group_name) : local.resource_group_name) : var.resource_group_hub_name
  vnet_name           = local.vnet_name
  storage_account     = var.resource_group_hub_name == "" ? azurerm_storage_account.mytfstorageacc.primary_blob_endpoint : module.network_hub.0.rg_hub_primary_blob_endpoint
  snet_id             = local.subnet_bastion_id
  snet_address_range  = local.subnet_bastion_address_range

  fortinet_enabled              = var.fortinet_enabled
  fortinet_bastion_public_ip    = local.fortinet_bastion_public_ip
  fortinet_bastion_public_ip_id = local.fortinet_bastion_public_ip_id
}
