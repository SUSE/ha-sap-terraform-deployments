provider "libvirt" {
  uri = var.qemu_uri
}

resource "libvirt_volume" "base_image" {
  name   = "${terraform.workspace}-baseimage"
  source = var.base_image
  pool   = var.storage_pool
}

# Internal network
resource "libvirt_network" "isolated_network" {
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
module "sbd_disk" {
  source            = "./modules/shared_disk"
  shared_disk_count = var.shared_storage_type == "shared-disk" ? 1 : 0
  name              = "sbd"
  pool              = var.storage_pool
  shared_disk_size  = 104857600
}

module "drbd_sbd_disk" {
  source            = "./modules/shared_disk"
  shared_disk_count = var.drbd_enabled == true && var.drbd_shared_storage_type == "shared-disk" ? 1 : 0
  name              = "drbd-sbd"
  pool              = var.storage_pool
  shared_disk_size  = 104857600
}

# Netweaver uses the shared disk for more things than only sbd
# Some SAP data is stored there to enable HA stack
module "nw_shared_disk" {
  source            = "./modules/shared_disk"
  shared_disk_count = var.netweaver_enabled == true ? 1 : 0
  name              = "netweaver-shared"
  pool              = var.storage_pool
  shared_disk_size  = 68719476736
}
