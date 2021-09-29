terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.3"
    }
  }
}

locals {
  hostname = var.common_variables["deployment_name_in_hostname"] ? format("%s-%s", var.common_variables["deployment_name"], var.name) : var.name
}

resource "libvirt_volume" "drbd_image_disk" {
  count            = var.drbd_count
  name             = "${var.common_variables["deployment_name"]}-${var.name}-${count.index + 1}-main-disk"
  source           = var.source_image
  base_volume_name = var.volume_name
  pool             = var.storage_pool
}

resource "libvirt_volume" "drbd_data_disk" {
  name  = "${var.common_variables["deployment_name"]}-${var.name}-${count.index + 1}-drbd-disk"
  pool  = var.storage_pool
  count = var.drbd_count
  size  = var.drbd_disk_size
}

resource "libvirt_domain" "drbd_domain" {
  name       = "${var.common_variables["deployment_name"]}-${var.name}${format("%02d", count.index + 1)}"
  memory     = var.memory
  vcpu       = var.vcpu
  count      = var.drbd_count
  qemu_agent = true
  dynamic "disk" {
    for_each = [
      {
        "vol_id" = element(libvirt_volume.drbd_image_disk.*.id, count.index)
      },
      {
        "vol_id" = element(libvirt_volume.drbd_data_disk.*.id, count.index)
      },
    ]
    content {
      volume_id = disk.value.vol_id
    }
  }

  // handle additional disks
  dynamic "disk" {
    for_each = slice(
      [
        {
          // we set null but it will never reached because the slice with 0 cut it off
          "volume_id" = var.sbd_storage_type == "shared-disk" ? var.sbd_disk_id : "null"
        },
    ], 0, var.fencing_mechanism == "sbd" && var.sbd_storage_type == "shared-disk" ? 1 : 0, )
    content {
      volume_id = disk.value.volume_id
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

  xml {
    xslt = file("modules/drbd_node/shareable.xsl")
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
    id                = libvirt_domain.drbd_domain.*.id
    name              = libvirt_domain.drbd_domain.*.name
    private_addresses = var.host_ips
    addresses         = libvirt_domain.drbd_domain.*.network_interface.0.addresses.0
  }
}

module "drbd_on_destroy" {
  source       = "../../../generic_modules/on_destroy"
  node_count   = var.drbd_count
  instance_ids = libvirt_domain.drbd_domain.*.id
  user         = "root"
  password     = "linux"
  public_ips   = libvirt_domain.drbd_domain.*.network_interface.0.addresses.0
  dependencies = [libvirt_domain.drbd_domain]
}
