terraform {
  required_version = ">= 0.13"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
# ibm terraform provider v1.33.1 deprecates pi_network_id replacing with pi_network which introduces new capabilities.
# Setting the provider to 1.33.0 keeps the Argument is deprecated warning from happening while pi_network_id is replaced.
      version = "1.33.0"
    }
  }
}

# Configure the IBM Cloud Provider
provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  zone             = var.zone
}

locals {
  deployment_name = var.deployment_name != "" ? var.deployment_name : terraform.workspace
  bastion_network_ids      = var.bastion_enabled && var.private_pi_network_ids != [] ? concat(var.public_pi_network_ids, var.private_pi_network_ids) : []
}

# Create shared disks for sbd
module "hana_sbd_disk" {
  source            = "./modules/shared_disk"
  common_variables  = module.common_variables.configuration
  ibmcloud_api_key              = var.ibmcloud_api_key
  region                        = var.region
  zone                          = var.zone
  pi_cloud_instance_id                = var.pi_cloud_instance_id
  shared_disk_count = var.hana_ha_enabled && var.hana_count > 1 && var.sbd_storage_type == "shared-disk" && var.hana_cluster_fencing_mechanism == "sbd" ? 1 : 0
  name              = "sbd"
  shared_disk_size  = var.sbd_disk_size
}

# Bastion
module "bastion" {
  source              = "./modules/bastion"
  common_variables    = module.common_variables.configuration
  ibmcloud_api_key              = var.ibmcloud_api_key
  region                        = var.region
  zone                          = var.zone
  pi_cloud_instance_id          = var.pi_cloud_instance_id
#  vm_size             = "Standard_B1s"
  vcpu                          = var.bastion_node_vcpu
  memory                        = var.bastion_node_memory
  os_image                      = local.bastion_os_image
  pi_sys_type                   = var.pi_sys_type
  pi_network_ids                = local.bastion_network_ids
  private_pi_network_names      = var.private_pi_network_names
  public_pi_network_names       = var.public_pi_network_names
  pi_key_pair_name              = var.pi_key_pair_name
  #snet_address_range  = cidrsubnet(local.vnet_address_range, 8, 2)
}
