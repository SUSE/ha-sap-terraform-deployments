terraform {
  required_version = ">= 1.1.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.14"
    }
  }
}

locals {
  hostname         = var.common_variables["deployment_name_in_hostname"] ? format("%s-%s", var.common_variables["deployment_name"], var.name) : var.name
  create_scale_out = var.hana_count > 1 && var.common_variables["hana"]["scale_out_enabled"] ? 1 : 0

  disks_number = length(split(",", var.hana_data_disks_configuration["disks_size"]))
  disks_size   = [for disk_size in split(",", var.hana_data_disks_configuration["disks_size"]) : tonumber(trimspace(disk_size))]
  disks = flatten([
    for node in range(var.hana_count) : [
      for disk in range(local.disks_number) : {
        node_num    = node
        node        = "${local.hostname}${format("%02d", node + 1)}"
        disk_number = disk
        disk_name   = "${local.hostname}${format("%02d-%s-%02d", node + 1, "disk", disk + 1)}"
        disk_size   = element(local.disks_size, disk) * 1024 * 1024 * 1024 # has to be passed in bytes instead of gigabytes
      }
    ]
  ])
}

resource "libvirt_volume" "hana_image_disk" {
  count            = var.hana_count
  name             = "${var.common_variables["deployment_name"]}-${var.name}-${count.index + 1}-main-disk"
  source           = var.source_image
  base_volume_name = var.volume_name
  pool             = var.storage_pool
  size             = 64424509440 # 60GB
}

resource "libvirt_volume" "hana_data_disk" {
  for_each = { for disk in local.disks : "${disk.disk_name}" => disk }

  name = each.value.disk_name
  pool = var.storage_pool
  size = each.value.disk_size
}

resource "libvirt_domain" "hana_domain" {
  name       = "${var.common_variables["deployment_name"]}-${var.name}${format("%02d", count.index + 1)}"
  memory     = var.memory
  vcpu       = var.vcpu
  count      = var.hana_count
  cloudinit  = var.userdata
  qemu_agent = true

  // handle root disk
  dynamic "disk" {
    for_each = [
      {
        "vol_id" = element(libvirt_volume.hana_image_disk.*.id, count.index)
      },
    ]
    content {
      volume_id = disk.value.vol_id
    }
  }

  // handle sbd disks
  dynamic "disk" {
    for_each = slice(
      [
        {
          // we set null but it will never reached because the slice with 0 cut it off
          "volume_id" = var.common_variables["hana"]["sbd_storage_type"] == "shared-disk" ? var.sbd_disk_id : "null"
        },
      ], 0, var.common_variables["hana"]["ha_enabled"] && var.common_variables["hana"]["fencing_mechanism"] == "sbd" && var.common_variables["hana"]["sbd_storage_type"] == "shared-disk" ? 1 : 0
    )
    content {
      volume_id = disk.value.volume_id
    }
  }

  // handle hana disks
  dynamic "disk" {
    for_each = { for disk in local.disks : "${disk.disk_name}" => disk if disk.node_num == count.index }
    content {
      volume_id = libvirt_volume.hana_data_disk[disk.value.disk_name].id
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
    xslt = file("modules/hana_node/shareable.xsl")
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

  cpu {
    mode = "host-passthrough"
  }
}

output "output_data" {
  value = {
    id                = libvirt_domain.hana_domain.*.id
    name              = libvirt_domain.hana_domain.*.name
    private_addresses = var.host_ips
    addresses         = libvirt_domain.hana_domain.*.network_interface.0.addresses.0
  }
}

module "hana_on_destroy" {
  source       = "../../../generic_modules/on_destroy"
  node_count   = var.hana_count
  instance_ids = libvirt_domain.hana_domain.*.id
  user         = "root"
  password     = "linux"
  public_ips   = libvirt_domain.hana_domain.*.network_interface.0.addresses.0
  dependencies = [libvirt_domain.hana_domain]
}
