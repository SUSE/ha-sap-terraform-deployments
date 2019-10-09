terraform {
  required_version = ">= 0.12"
}

resource "libvirt_volume" "monitoring_main_disk" {
  name            = format("%s-monitoring-disk", terraform.workspace)
  source          = var.monitoring_image
  base_volume_id  = var.monitoring_image == "" ? var.base_image_id: ""
  pool            = var.pool
  count           = var.monitoring_count
}

resource "libvirt_domain" "monitoring_domain" {
  name       = "${terraform.workspace}-${var.name}"
  count      = var.monitoring_count
  memory     = var.memory
  vcpu       = var.vcpu
  qemu_agent = true
  dynamic "disk" {
    for_each = [
        {
          "vol_id" = element(libvirt_volume.monitoring_main_disk.*.id, count.index)
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
    hostname       = "${terraform.workspace}-${var.name}"
    addresses      = [var. monitoring_srv_ip]
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
    id                = libvirt_domain.monitoring_domain.*.id
    hostname          = libvirt_domain.monitoring_domain.*.name
    private_addresses = [var. monitoring_srv_ip]
    addresses         = libvirt_domain.monitoring_domain.*.network_interface.0.addresses.0
  }
}
