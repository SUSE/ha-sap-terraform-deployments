# Availability set for the hana VMs

provider "ibm" {
    ibmcloud_api_key = var.ibmcloud_api_key
    region = var.region
    zone = var.zone
}

## hana instances

locals {
  bastion_enabled       = var.common_variables["bastion_enabled"]
  create_shared_infra   = var.hana_count > 1 && var.common_variables["hana"]["ha_enabled"] && var.common_variables["hana"]["fencing_mechanism"] == "sbd" && var.common_variables["hana"]["sbd_storage_type"] == "shared-disk" ? 1 : 0
  disks_number          = length(split(",", var.hana_data_disks_configuration["disks_size"]))
  disks_size            = [for disk_size in split(",", var.hana_data_disks_configuration["disks_size"]) : tonumber(trimspace(disk_size))]
  disks_type            = [for disk_type in split(",", var.hana_data_disks_configuration["disks_type"]) : trimspace(disk_type)]
  provisioning_addresses      = local.bastion_enabled ? data.ibm_pi_instance_ip.ibm_pi_hana_private.*.ip : data.ibm_pi_instance_ip.ibm_pi_hana_public.*.external_ip
}

resource "ibm_pi_volume" "ibm_pi_hana_volume"{
  count                = var.hana_count * local.disks_number
  pi_volume_size       = local.disks_size[count.index - (local.disks_number * floor(count.index / local.disks_number))]
  pi_volume_name       = "${terraform.workspace}-${var.name}-volume${count.index + 1}"
  pi_volume_type       = local.disks_type[count.index - (local.disks_number * floor(count.index / local.disks_number))]
  pi_volume_shareable  = false
  pi_cloud_instance_id = var.pi_cloud_instance_id
}

resource "ibm_pi_instance" "ibm_pi_hana" {
  count                 = var.hana_count
  pi_cloud_instance_id  = var.pi_cloud_instance_id
  pi_key_pair_name      = var.pi_key_pair_name
  pi_sys_type           = var.pi_sys_type
  pi_proc_type          = "shared"
  pi_image_id           = var.os_image
  pi_instance_name      = "${terraform.workspace}-${var.name}0${count.index + 1}"
  pi_memory             = var.memory
  pi_processors         = var.vcpu
  pi_network_ids        = var.pi_network_ids
  pi_replicants         = 1
  pi_replication_scheme = "suffix"
  pi_pin_policy         = "none"
  pi_replication_policy = "none"
  pi_health_status      = "OK"
  pi_volume_ids         = concat([for n in range((count.index * local.disks_number),((count.index + 1) * local.disks_number)) : ibm_pi_volume.ibm_pi_hana_volume[n].volume_id], local.create_shared_infra == 1 ? [var.sbd_disk_id] : [])
  timeouts {
    create = "15m"
    delete = "15m"
  }
}
