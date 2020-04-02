resource "libvirt_volume" "netweaver_main_disk" {
  name             = "${terraform.workspace}-${var.name}${var.netweaver_count > 1 ? "-${count.index + 1}" : ""}-main-disk"
  base_volume_id   = var.base_image_id
  pool             = var.pool
  count            = var.netweaver_count
}

resource "libvirt_domain" "netweaver_domain" {
  name       = "${terraform.workspace}-${var.name}${var.netweaver_count > 1 ? "-${count.index + 1}" : ""}"
  memory     = var.memory
  vcpu       = var.vcpu
  count      = var.netweaver_count
  qemu_agent = true

  dynamic "disk" {
    for_each = [
        {
          "vol_id" = element(libvirt_volume.netweaver_main_disk.*.id, count.index)
        },
        {
          "vol_id" = var.shared_disk_id
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
    network_id     = var.network_id
    hostname       = "${var.name}${var.netweaver_count > 1 ? "0${count.index + 1}" : ""}"
    addresses      = [element(var.host_ips, count.index)]
  }

  xml {
    xslt = file("modules/netweaver_node/shareable.xls")
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
    id                = libvirt_domain.netweaver_domain.*.id
    hostname          = libvirt_domain.netweaver_domain.*.name
    private_addresses = var.host_ips
    addresses         = libvirt_domain.netweaver_domain.*.network_interface.0.addresses.0
  }
}
