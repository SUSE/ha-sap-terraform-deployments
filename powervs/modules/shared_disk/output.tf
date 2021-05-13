data "ibm_pi_volume" "ibm_pi_shared_disk" {
  count                = var.shared_disk_count
  pi_volume_name      = "${terraform.workspace}-${var.name}"
  pi_cloud_instance_id  = var.pi_cloud_instance_id
  # depends_on is included to avoid the issue with `resource_group was not found`.
  depends_on            = [ibm_pi_volume.ibm_pi_shared_disk]
}
