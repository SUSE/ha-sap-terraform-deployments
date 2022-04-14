locals {
  fortinet_bastion_public_ip    = var.fortinet_enabled ? module.fortigate.0.bastion_public_ip : null
  fortinet_bastion_public_ip_id = var.fortinet_enabled ? module.fortigate.0.bastion_public_ip_id : null
  bastion_private_ip            = var.fortinet_enabled ? (var.fortinet_bastion_private_ip == "" ? cidrhost(module.network_hub.0.subnet_hub_mgmt_address_range, 5) : var.fortinet_bastion_private_ip) : null

  resource_group_name_ftnt = var.resource_group_hub_name == "" ? (var.resource_group_hub_create ? format("%s-hub", local.resource_group_name) : local.resource_group_name) : var.resource_group_hub_name

  fortigate_a_provisioned = var.fortinet_enabled ? module.fortigate.0.fortigate_a_id : null
  fortigate_b_provisioned = var.fortinet_enabled ? module.fortigate.0.fortigate_b_id : null

  bastion_host = var.bastion_host != "" ? var.bastion_host : (var.fortinet_enabled ? local.fortinet_bastion_public_ip : (var.bastion_enabled ? module.bastion.0.public_ip : ""))

}

resource "random_id" "random_id" {

  count = var.fortinet_enabled ? 1 : 0
  keepers = {
    resource_group_name = local.resource_group_name_ftnt
  }

  byte_length = 8
}
resource "azurerm_storage_account" "storage_account" {

  count = var.fortinet_enabled ? 1 : 0

  resource_group_name      = local.resource_group_name_ftnt
  location                 = var.az_region
  name                     = format("%s%s", "sadiag", random_id.random_id[count.index].hex)
  account_replication_type = "LRS"
  account_tier             = "Standard"
}

data "azurerm_resource_group" "resource_group" {
  count = var.fortinet_enabled ? 1 : 0

  name = local.resource_group_name_ftnt

  depends_on = [
    azurerm_resource_group.rg
  ]
}
module "fortigate" {
  count = var.fortinet_enabled ? 1 : 0

  source                   = "./modules/fortinet/fortigate"
  common_variables         = module.common_variables.configuration
  az_region                = var.az_region
  vnet_address_range       = var.vnet_hub_address_range
  vnet_spoke_address_range = var.vnet_address_range
  os_image                 = var.fortigate_os_image
  vm_license               = var.fortinet_vm_license_type
  vm_size                  = var.fortigate_vm_size
  vm_username              = var.fortigate_vm_username
  vm_password              = var.fortigate_vm_password

  bastion_private_ip    = local.bastion_private_ip
  netweaver_private_ips = local.netweaver_ips

  resource_group_name = local.resource_group_name_ftnt
  resource_group_id   = data.azurerm_resource_group.resource_group[count.index].id
  storage_account     = azurerm_storage_account.storage_account[count.index].primary_blob_endpoint
  snet_ids = {
    "external-fgt"         = module.network_hub.0.subnet-hub-external-fgt.0.id
    "internal-fgt"         = module.network_hub.0.subnet-hub-internal-fgt.0.id
    "hasync-ftnt"          = module.network_hub.0.subnet-hub-hasync-ftnt.0.id
    "mgmt-ftnt"            = module.network_hub.0.subnet-hub-mgmt-ftnt.0.id
    "external-fadc"        = module.network_hub.0.subnet-hub-external-fadc.0.id
    "internal-fadc"        = module.network_hub.0.subnet-hub-internal-fadc.0.id
    "mgmt"                 = module.network_hub.0.subnet_hub_mgmt_id
    "mon"                  = module.network_hub.0.subnet_hub_mon_id
    "spoke-sap-1-workload" = module.network_spoke.0.subnet_spoke_workload_id
  }

  snet_address_ranges = {
    "external-fgt"  = module.network_hub.0.subnet-hub-external-fgt-address-range
    "internal-fgt"  = module.network_hub.0.subnet-hub-internal-fgt-address-range
    "hasync-ftnt"   = module.network_hub.0.subnet-hub-hasync-ftnt-address-range
    "mgmt-ftnt"     = module.network_hub.0.subnet-hub-mgmt-ftnt-address-range
    "external-fadc" = module.network_hub.0.subnet-hub-external-fadc-address-range
    "internal-fadc" = module.network_hub.0.subnet-hub-internal-fadc-address-range
    "mgmt"          = module.network_hub.0.subnet_hub_mgmt_address_range
    "mon"           = module.network_hub.0.subnet_hub_mon_address_range
  }
  fortinet_licenses = {
    "license_a" = "${path.module}/${var.fortigate_a_license_file}"
    "license_b" = "${path.module}/${var.fortigate_b_license_file}"
  }
}

module "fortiadc" {
  count = var.fortinet_enabled ? 1 : 0

  source             = "./modules/fortinet/fortiadc"
  common_variables   = module.common_variables.configuration
  az_region          = var.az_region
  vnet_address_range = var.vnet_hub_address_range
  os_image           = var.fortiadc_os_image
  vm_license         = var.fortinet_vm_license_type
  vm_size            = var.fortiadc_vm_size
  vm_username        = var.fortiadc_vm_username
  vm_password        = var.fortiadc_vm_password

  resource_group_name = local.resource_group_name_ftnt
  resource_group_id   = data.azurerm_resource_group.resource_group[count.index].id
  storage_account     = azurerm_storage_account.storage_account[count.index].primary_blob_endpoint

  random_id = random_id.random_id.0.hex
  snet_ids = {
    "external-fgt"         = module.network_hub.0.subnet-hub-external-fgt.0.id
    "internal-fgt"         = module.network_hub.0.subnet-hub-internal-fgt.0.id
    "hasync-ftnt"          = module.network_hub.0.subnet-hub-hasync-ftnt.0.id
    "mgmt-ftnt"            = module.network_hub.0.subnet-hub-mgmt-ftnt.0.id
    "external-fadc"        = module.network_hub.0.subnet-hub-external-fadc.0.id
    "internal-fadc"        = module.network_hub.0.subnet-hub-internal-fadc.0.id
    "mgmt"                 = module.network_hub.0.subnet_hub_mgmt_id
    "mon"                  = module.network_hub.0.subnet_hub_mon_id
    "spoke-sap-1-workload" = module.network_spoke.0.subnet_spoke_workload_id
  }
  snet_address_ranges = {
    "external-fgt"  = module.network_hub.0.subnet-hub-external-fgt-address-range
    "internal-fgt"  = module.network_hub.0.subnet-hub-internal-fgt-address-range
    "hasync-ftnt"   = module.network_hub.0.subnet-hub-hasync-ftnt-address-range
    "mgmt-ftnt"     = module.network_hub.0.subnet-hub-mgmt-ftnt-address-range
    "external-fadc" = module.network_hub.0.subnet-hub-external-fadc-address-range
    "internal-fadc" = module.network_hub.0.subnet-hub-internal-fadc-address-range
    "mgmt"          = module.network_hub.0.subnet_hub_mgmt_address_range
    "mon"           = module.network_hub.0.subnet_hub_mon_address_range
  }
  fortinet_licenses = {
    "license_a" = "${path.module}/${var.fortiadc_a_license_file}"
    "license_b" = "${path.module}/${var.fortiadc_b_license_file}"
  }
}
