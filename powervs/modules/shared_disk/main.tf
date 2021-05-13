provider "ibm" {
    ibmcloud_api_key = var.ibmcloud_api_key
    region = var.region
    zone = var.zone
}

resource "ibm_pi_volume" "ibm_pi_shared_disk"{
  count                = var.shared_disk_count
  pi_volume_size       = var.shared_disk_size
  pi_volume_name       = "${terraform.workspace}-${var.name}"
  pi_volume_type       = var.shared_type
  pi_volume_shareable  = true
  pi_cloud_instance_id = var.pi_cloud_instance_id
}

output "id" {
  value = join(",", ibm_pi_volume.ibm_pi_shared_disk.*.volume_id)
}

output "wwn" {
  value = join(",", data.ibm_pi_volume.ibm_pi_shared_disk.*.wwn)
}
