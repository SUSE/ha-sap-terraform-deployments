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

resource "libvirt_volume" "iscsi_image_disk" {
  count            = var.iscsi_count
  name             = format("%s-iscsi-disk-%s", var.common_variables["deployment_name"], count.index + 1)
  source           = var.source_image
  base_volume_name = var.volume_name
  pool             = var.storage_pool
}

resource "libvirt_volume" "iscsi_dev_disk" {
  count = var.iscsi_count
  name  = format("%s-iscsi-dev-%s", var.common_variables["deployment_name"], count.index + 1)
  pool  = var.storage_pool
  size  = var.iscsi_disk_size
}

resource "libvirt_domain" "iscsisrv" {
  name       = "${var.common_variables["deployment_name"]}-${var.name}${format("%02d", count.index + 1)}"
  memory     = var.memory
  vcpu       = var.vcpu
  count      = var.iscsi_count
  qemu_agent = true

  dynamic "disk" {
    for_each = [
      {
        "vol_id" = element(libvirt_volume.iscsi_image_disk.*.id, count.index)
      },
      {
        "vol_id" = element(libvirt_volume.iscsi_dev_disk.*.id, count.index)
    }]
    content {
      volume_id = disk.value.vol_id
    }
  }

  network_interface {
    network_name   = var.nat_network_name
    bridge         = var.bridge
    mac            = var.mac
    wait_for_lease = true
  }

  network_interface {
    network_name = var.isolated_network_name
    network_id   = var.isolated_network_id
    mac          = var.mac
    addresses    = [element(var.host_ips, count.index)]
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
    id                = libvirt_domain.iscsisrv.*.id
    name              = libvirt_domain.iscsisrv.*.name
    private_addresses = var.host_ips
    addresses         = libvirt_domain.iscsisrv.*.network_interface.0.addresses.0
  }
}

module "iscsi_on_destroy" {
  source       = "../../../generic_modules/on_destroy"
  node_count   = var.iscsi_count
  instance_ids = libvirt_domain.iscsisrv.*.id
  user         = "root"
  password     = "linux"
  public_ips   = libvirt_domain.iscsisrv.*.network_interface.0.addresses.0
  dependencies = [libvirt_domain.iscsisrv]
}
