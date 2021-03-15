data "ibm_pi_instance" "ibm_pi_hana" {
  count                 = var.hana_count
  pi_instance_name      = "${terraform.workspace}-${var.name}0${count.index + 1}"
  pi_cloud_instance_id  = var.pi_cloud_instance_id
  # depends_on is included to avoid the issue with `resource_group was not found`.
  depends_on            = [ibm_pi_instance.ibm_pi_hana]
}

data "ibm_pi_volume" "ibm_pi_hana_volume" {
  count                = var.hana_count * local.disks_number
  pi_volume_name      = "${terraform.workspace}-${var.name}-volume${count.index + 1}"
  pi_cloud_instance_id  = var.pi_cloud_instance_id
  # depends_on is included to avoid the issue with `resource_group was not found`.
  depends_on            = [ibm_pi_volume.ibm_pi_hana_volume]
}
