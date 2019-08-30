resource "libvirt_volume" "sbd" {
  name  = "${terraform.workspace}-sbd.raw"
  pool  = var.pool
  size  = var.sbd_disk_size
  count = var.sbd_count

  xml {
    xslt = file("modules/hana_node/raw.xsl")
  }
}

resource "libvirt_volume" "main_disk" {
  name             = "${terraform.workspace}-${var.name}${var.hana_count > 1 ? "-${count.index + 1}" : ""}-main-disk"
  base_volume_id   = var.base_image_id
  pool             = var.pool
  count            = var.hana_count
}

resource "libvirt_volume" "hana_disk" {
  name  = "${terraform.workspace}-${var.name}${var.hana_count > 1 ? "-${count.index + 1}" : ""}-hana-disk"
  pool  = var.pool
  count = var.hana_count
  size  = var.hana_disk_size
}

resource "libvirt_domain" "hana_domain" {
  name       = "${terraform.workspace}-${var.name}${var.hana_count > 1 ? "-${count.index + 1}" : ""}"
  memory     = var.memory
  vcpu       = var.vcpu
  count      = var.hana_count
  qemu_agent = true
   dynamic "disk" {
    for_each = [
        {
          "vol_id" = element(libvirt_volume.main_disk.*.id, count.index)
        },
        {
          "vol_id" = element(libvirt_volume.hana_disk.*.id, count.index)
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
        "volume_id" =  var.shared_storage_type == "shared-disk" ?  libvirt_volume.sbd.0.id : "null"
      },
    ], 0,  var.shared_storage_type == "shared-disk" ? 1 : 0,  )
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
    network_id     = var.network_id
    hostname       = "${var.name}${var.hana_count > 1 ? "0${count.index + 1}" : ""}"
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

  cpu = {
    mode = "host-passthrough"
  }
}

output "configuration" {
  value = {
    id       = libvirt_domain.hana_domain.*.id
    hostname = libvirt_domain.hana_domain.*.name
  }
}

output "addresses" {
  value = flatten(libvirt_domain.hana_domain.*.network_interface.0.addresses)
}
