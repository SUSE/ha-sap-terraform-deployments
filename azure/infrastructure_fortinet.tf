module "fortigate" {
  count               = var.fortinet_enabled ? 1 : 0
  source              = "./modules/fortinet/fortigate"
  common_variables    = module.common_variables.configuration
  az_region           = var.az_region
  vnet_address_range  = var.vnet_address_range
  vm_offer            = "fortinet_fortigate-vm_v5"
  vm_sku              = "fortinet_fg-vm"
  vm_publisher        = "fortinet"
  vm_size             = "Standard_F4s"
  vm_license          = "byol"
  vm_version          = "7.0.1"
  vm_username         = "azureuser"
  vm_password         = "Password123!!"
  resource_group_name = var.resource_group_hub_name == "" ? (var.resource_group_hub_create ? format("%s-hub", local.resource_group_name) : local.resource_group_name) : var.resource_group_hub_name
  storage_account     = var.resource_group_hub_name == "" ? azurerm_storage_account.mytfstorageacc.primary_blob_endpoint : module.network_hub.0.rg_hub_primary_blob_endpoint
  snet_ids = [
    module.network_hub.0.subnet-hub-dmz.0.id,
    module.network_hub.0.subnet-hub-hasync.0.id,
    module.network_hub.0.subnet-hub-shared-services.0.id,
    module.network_hub.0.subnet-hub-fortinet-mgmt.0.id
  ]

  snet_address_ranges = [
    module.network_hub.0.subnet-hub-dmz-address-range,
    module.network_hub.0.subnet-hub-hasync-address-range,
    module.network_hub.0.subnet-hub-shared-services-address-range,
    module.network_hub.0.subnet-hub-fortinet-mgmt-address-range
  ]
}

#module "fortiadc" {
#  count               = var.fortinet_enabled ? 1 : 0
#  source              = "./modules/fortinet/fortigate"
#  network_topology    = var.network_topology
#  common_variables    = module.common_variables.configuration
#  az_region           = var.az_region
#  os_image            = local.bastion_os_image
#  vm_size             = "Standard_B1s"
#  resource_group_name = var.resource_group_hub_name == "" ? (var.resource_group_hub_create ? format("%s-hub", local.resource_group_name) : local.resource_group_name) : var.resource_group_hub_name
#  vnet_name           = local.vnet_name
#  storage_account     = var.resource_group_hub_name == "" ? azurerm_storage_account.mytfstorageacc.primary_blob_endpoint : module.network_hub.0.rg_hub_primary_blob_endpoint
#  snet_id             = local.subnet_bastion_id
#  snet_address_range  = local.subnet_bastion_address_range
#}