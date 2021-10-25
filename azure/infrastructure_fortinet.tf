module "fortigate" {
  count               = var.fortinet_enabled ? 1 : 0

  source              = "./modules/fortinet/fortigate"
  common_variables    = module.common_variables.configuration
  az_region           = var.az_region
  vnet_address_range  = var.vnet_address_range
  vm_publisher        = var.fortinet_vm_publisher
  vm_license          = var.fortinet_vm_license_type
  vm_offer            = var.fortigate_vm_offer
  vm_sku              = var.fortigate_vm_sku
  vm_size             = var.fortigate_vm_size
  vm_version          = var.fortigate_vm_version
  vm_username         = var.fortigate_vm_username
  vm_password         = var.fortigate_vm_password

  resource_group_name = var.resource_group_hub_name == "" ? (var.resource_group_hub_create ? format("%s-hub", local.resource_group_name) : local.resource_group_name) : var.resource_group_hub_name
  storage_account     = var.resource_group_hub_name == "" ? azurerm_storage_account.mytfstorageacc.primary_blob_endpoint : module.network_hub.0.rg_hub_primary_blob_endpoint
  snet_ids = [
    module.network_hub.0.subnet-hub-dmz.0.id,
    module.network_hub.0.subnet-hub-shared-services.0.id,
    module.network_hub.0.subnet-hub-hasync.0.id,
    module.network_hub.0.subnet-hub-fortinet-mgmt.0.id
  ]

  snet_address_ranges = [
    module.network_hub.0.subnet-hub-dmz-address-range,
    module.network_hub.0.subnet-hub-shared-services-address-range,
    module.network_hub.0.subnet-hub-hasync-address-range,
    module.network_hub.0.subnet-hub-fortinet-mgmt-address-range
  ]
  fortinet_licenses = {
    "license_a"  = "${path.module}/${var.fortigate_a_license_file}"
    "license_b"  = "${path.module}/${var.fortigate_b_license_file}"
  }
}

module "fortiadc" {
  count               = var.fortinet_enabled ? 1 : 0

  source              = "./modules/fortinet/fortiadc"
  common_variables    = module.common_variables.configuration
  az_region           = var.az_region
  vnet_address_range  = var.vnet_address_range
  vm_publisher        = var.fortinet_vm_publisher
  vm_license          = var.fortinet_vm_license_type
  vm_offer            = var.fortiadc_vm_offer
  vm_sku              = var.fortiadc_vm_sku
  vm_size             = var.fortiadc_vm_size
  vm_version          = var.fortiadc_vm_version
  vm_username         = var.fortiadc_vm_username
  vm_password         = var.fortiadc_vm_password
  
  resource_group_name = var.resource_group_hub_name == "" ? (var.resource_group_hub_create ? format("%s-hub", local.resource_group_name) : local.resource_group_name) : var.resource_group_hub_name
  storage_account     = var.resource_group_hub_name == "" ? azurerm_storage_account.mytfstorageacc.primary_blob_endpoint : module.network_hub.0.rg_hub_primary_blob_endpoint
  snet_ids = [
    module.network_hub.0.subnet-hub-dmz.0.id,
    module.network_hub.0.subnet-hub-shared-services.0.id,
    module.network_hub.0.subnet-hub-hasync.0.id,
    module.network_hub.0.subnet-hub-fortinet-mgmt.0.id
  ]

  snet_address_ranges = [
    module.network_hub.0.subnet-hub-dmz-address-range,
    module.network_hub.0.subnet-hub-shared-services-address-range,
    module.network_hub.0.subnet-hub-hasync-address-range,
    module.network_hub.0.subnet-hub-fortinet-mgmt-address-range
  ]
  fortinet_licenses = {
    "license_a"  = "${path.module}/${var.fortigate_a_license_file}"
    "license_b"  = "${path.module}/${var.fortigate_b_license_file}"
  }

}