locals {
  bastion_count      = var.common_variables["bastion_enabled"] ? 1 : 0
  #private_ip_address = cidrhost(var.snet_address_range, 5)
  userdata_bastion   = templatefile("${path.module}/userdata_bastion.tpl", {})
}

  resource "ibm_pi_instance" "bastion" {
    count                 = local.bastion_count
    pi_cloud_instance_id  = var.pi_cloud_instance_id
    pi_key_pair_name      = var.pi_key_pair_name
    pi_sys_type           = var.pi_sys_type
    pi_proc_type          = "shared"
    pi_image_id           = var.os_image
    pi_instance_name      = "${terraform.workspace}-bastion"
    pi_memory             = var.memory
    pi_processors         = var.vcpu
    pi_network_ids        = var.pi_network_ids
    pi_volume_ids         = []
    pi_replicants         = 1
    pi_replication_scheme = "suffix"
    pi_user_data          = base64encode(local.userdata_bastion)
    pi_pin_policy         = "none"
    pi_replication_policy = "none"
    pi_storage_type       = var.pi_storage_type
    pi_health_status      = "OK"
    timeouts {
      create = "15m"
      delete = "15m"
    }
  }
