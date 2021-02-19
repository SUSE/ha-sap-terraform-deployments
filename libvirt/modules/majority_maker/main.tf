resource "libvirt_volume" "majority_maker_image_disk" {
  count            = var.majority_maker_enabled == true ? 1 : 0
  name             = format("%s-majority-maker-disk", var.common_variables["deployment_name"])
  source           = var.source_image
  base_volume_name = var.volume_name
  pool             = var.storage_pool
}

# To remove later
resource "libvirt_volume" "dummy_disk" {
  count  = var.majority_maker_enabled == true ? 1 : 0
  name  = "${var.common_variables["deployment_name"]}-${var.name}-dummy-disk"
  pool  = var.storage_pool
  size  = 1024
}

resource "libvirt_domain" "majority_maker_domain" {
  count      = var.majority_maker_enabled == true ? 1 : 0
  name       = "${var.common_variables["deployment_name"]}-majority-maker"
  memory     = var.memory
  vcpu       = var.vcpu
  qemu_agent = true

  disk {
    volume_id = libvirt_volume.majority_maker_image_disk.0.id
  }

  # to remove later
  disk {
    volume_id = libvirt_volume.dummy_disk.0.id
  }

  // handle additional disks
  dynamic "disk" {
    for_each = slice(
      [
        {
          // we set null but it will never reached because the slice with 0 cut it off
          "volume_id" = var.sbd_storage_type == "shared-disk" ? var.sbd_disk_id : "null"
        },
      ], 0, var.sbd_enabled && var.sbd_storage_type == "shared-disk" ? 1 : 0
    )
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
    addresses      = [var.majority_maker_ip]
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

  cpu = {
    mode = "host-passthrough"
  }
}

output "output_data" {
  value = {
    id              = join("", libvirt_domain.majority_maker_domain.*.id)
    name            = join("", libvirt_domain.majority_maker_domain.*.name)
    private_address = var.majority_maker_ip
    address         = join("", libvirt_domain.majority_maker_domain.*.network_interface.0.addresses.0)
  }
}

module "monitoring_on_destroy" {
  source       = "../../../generic_modules/on_destroy"
  node_count   = var.majority_maker_enabled ? 1 : 0
  instance_ids = libvirt_domain.majority_maker_domain.*.id
  user         = "root"
  password     = "linux"
  public_ips   = libvirt_domain.majority_maker_domain.*.network_interface.0.addresses.0
  dependencies = [libvirt_domain.majority_maker_domain]
}