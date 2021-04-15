terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.3"
    }
  }
}

resource "libvirt_volume" "nfs_server_image_disk" {
  count            = var.nfs_server_count
  name             = "${var.common_variables["deployment_name"]}-${var.name}-${count.index + 1}-main-disk"
  source           = var.source_image
  base_volume_name = var.volume_name
  pool             = var.storage_pool
}

resource "libvirt_volume" "nfs_server_data_disk" {
  name  = "${var.common_variables["deployment_name"]}-${var.name}-${count.index + 1}-nfs-disk"
  pool  = var.storage_pool
  count = var.nfs_server_count
  size  = var.nfs_server_disk_size
}

resource "libvirt_domain" "nfs_server_domain" {
  name       = "${var.common_variables["deployment_name"]}-${var.name}-${count.index + 1}"
  memory     = var.memory
  vcpu       = var.vcpu
  count      = var.nfs_server_count
  qemu_agent = true
  dynamic "disk" {
    for_each = [
      {
        "vol_id" = element(libvirt_volume.nfs_server_image_disk.*.id, count.index)
      },
      {
        "vol_id" = element(libvirt_volume.nfs_server_data_disk.*.id, count.index)
      },
    ]
    content {
      volume_id = disk.value.vol_id
    }
  }

  network_interface {
    wait_for_lease = true
    network_name   = var.network_name
    bridge         = var.bridge
    mac            = var.mac
  }

  network_interface {
    wait_for_lease = false
    network_name   = var.isolated_network_name
    network_id     = var.isolated_network_id
    addresses      = [element(var.host_ips, count.index)]
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  cpu = {
    mode = "host-passthrough"
  }
}

output "output_data" {
  value = {
    id                = libvirt_domain.nfs_server_domain.*.id
    name              = libvirt_domain.nfs_server_domain.*.name
    private_addresses = var.host_ips
    addresses         = libvirt_domain.nfs_server_domain.*.network_interface.0.addresses.0
  }
}

module "nfs_server_on_destroy" {
  source       = "../../../generic_modules/on_destroy"
  node_count   = var.nfs_server_count
  instance_ids = libvirt_domain.nfs_server_domain.*.id
  user         = "root"
  password     = "linux"
  public_ips   = libvirt_domain.nfs_server_domain.*.network_interface.0.addresses.0
  dependencies = [libvirt_domain.nfs_server_domain]
}
