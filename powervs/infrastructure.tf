terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = "> 1.21"
    }
  }
  required_version = ">= 0.13"
}

locals {
  deployment_name = var.deployment_name != "" ? var.deployment_name : terraform.workspace
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
