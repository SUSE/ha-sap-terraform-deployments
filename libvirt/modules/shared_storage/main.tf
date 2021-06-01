locals {

  # Check if shared storage type is "drbd"
  drbd_enabled = var.shared_storage_enabled && shared_storage_type == "drbd"
}

module "drbd_node" {
  source                = "./drbd_node"
  common_variables      = module.common_variables.configuration
  name                  = "drbd"
  source_image          = var.drbd_source_image
  volume_name           = var.drbd_source_image != "" ? "" : (var.drbd_volume_name != "" ? var.drbd_volume_name : local.generic_volume_name)
  drbd_count            = local.drbd_enabled == true ? 2 : 0
  vcpu                  = var.drbd_node_vcpu
  memory                = var.drbd_node_memory
  bridge                = "br0"
  host_ips              = var.drbd_ips
  drbd_cluster_vip      = var.drbd_cluster_vip
  drbd_disk_size        = var.drbd_disk_size
  fencing_mechanism     = var.drbd_cluster_fencing_mechanism
  sbd_storage_type      = var.sbd_storage_type
  sbd_disk_id           = module.drbd_sbd_disk.id
  iscsi_srv_ip          = module.iscsi_server.output_data.private_addresses.0
  isolated_network_id   = var.internal_network_id
  isolated_network_name = var.internal_network_name
  storage_pool          = var.storage_pool
  nfs_mounting_point    = var.drbd_nfs_mounting_point
  nfs_export_name       = var.nfs_export_name
}
