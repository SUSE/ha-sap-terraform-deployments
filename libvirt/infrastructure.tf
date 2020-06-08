provider "libvirt" {
  uri = var.qemu_uri
}

locals {
  internal_network_name = var.network_name
  internal_network_id   = var.network_name != "" ? "" : libvirt_network.isolated_network.0.id
  generic_volume_name   = var.source_image != "" ? libvirt_volume.base_image.0.name : var.volume_name != "" ? var.volume_name : ""
  iprange               = var.iprange
}

resource "libvirt_volume" "base_image" {
  count  = var.source_image != "" ? 1 : 0
  name   = "${terraform.workspace}-baseimage"
  source = var.source_image
  pool   = var.storage_pool
}

# Internal network
resource "libvirt_network" "isolated_network" {
  count     = var.network_name == "" ? 1 : 0
  name      = "${terraform.workspace}-isolated"
  bridge    = var.isolated_network_bridge
  mode      = "none"
  addresses = [var.iprange]
  dhcp {
    enabled = "false"
  }
  dns {
    enabled = true
  }
  autostart = true
}

# Create shared disks for sbd
module "hana_sbd_disk" {
  source            = "./modules/shared_disk"
  shared_disk_count = var.hana_count > 1 && var.sbd_storage_type == "shared-disk" && var.hana_cluster_sbd_enabled == true ? 1 : 0
  name              = "sbd"
  pool              = var.storage_pool
  shared_disk_size  = var.sbd_disk_size
}

module "drbd_sbd_disk" {
  source            = "./modules/shared_disk"
  shared_disk_count = var.drbd_enabled && var.sbd_storage_type == "shared-disk" && var.drbd_cluster_sbd_enabled == true ? 1 : 0
  name              = "drbd-sbd"
  pool              = var.storage_pool
  shared_disk_size  = var.sbd_disk_size
}

# Netweaver uses the shared disk for more things than only sbd
# Some SAP data is stored there to enable HA stack
module "netweaver_shared_disk" {
  source            = "./modules/shared_disk"
  shared_disk_count = var.netweaver_enabled && var.netweaver_ha_enabled ? 1 : 0
  name              = "netweaver-shared"
  pool              = var.storage_pool
  shared_disk_size  = var.netweaver_shared_disk_size
}
