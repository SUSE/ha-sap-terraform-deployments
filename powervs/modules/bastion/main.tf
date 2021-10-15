locals {
  bastion_count      = var.common_variables["bastion_enabled"] ? 1 : 0
  #private_ip_address = cidrhost(var.snet_address_range, 5)
  userdata_bastion   = templatefile("${path.module}/userdata_bastion.tpl", {})
}

# 2021-06-30 Adding a volume is a workaround so the bastion instance will be created
#   https://github.com/IBM-Cloud/terraform-provider-ibm/issues/2787
#   The need for an extra volume can be removed once https://github.com/IBM-Cloud/terraform-provider-ibm/pull/2797
#   is released.
resource "ibm_pi_volume" "bastion_volume"{
  count                = local.bastion_count
  pi_volume_size       = 10
  pi_volume_name       = "bastion-volume"
  pi_volume_type       = "tier1"
  pi_volume_shareable  = false
  pi_cloud_instance_id = "94ded72b-b08d-4618-b60d-5c3da2dcd3f8"
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
    pi_volume_ids         = [ibm_pi_volume.bastion_volume[count.index].volume_id]
    pi_replicants         = 1
    pi_replication_scheme = "suffix"
    pi_user_data          = base64encode(local.userdata_bastion)
    pi_pin_policy         = "none"
    pi_replication_policy = "none"
    pi_health_status      = "OK"
    timeouts {
      create = "30m"
      delete = "30m"
    }
    depends_on            = [ibm_pi_volume.bastion_volume]
  }
