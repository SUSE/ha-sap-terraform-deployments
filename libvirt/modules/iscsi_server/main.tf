terraform {
  required_version = ">= 0.12"
}

resource "libvirt_volume" "iscsi_image_disk" {
  name   = format("%s-iscsi-disk", terraform.workspace) 
  source = var.iscsi_image
  pool   = var.base_configuration["pool"]
  count  = var.iscsi_count
}

resource "libvirt_volume" "iscsi_dev_disk" {
  name  = format("%s-iscsi-dev", terraform.workspace)
  pool  = var.base_configuration["pool"]
  size  = "10000000000"                       # 10GB
  count = var.iscsi_count
}

resource "libvirt_domain" "iscsisrv" {
  name       = format("%s-iscsi", terraform.workspace)
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
    network_name   = var.base_configuration["network_name"]
    bridge         = var.base_configuration["bridge"]
    mac            = var.mac
    wait_for_lease = true
  }

  network_interface {
    network_id = var.network_id
    mac        = var.mac
    addresses  = [var.iscsi_srv_ip]
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
    id       = join(",", libvirt_domain.iscsisrv.*.id)
    hostname = join(",", libvirt_domain.iscsisrv.*.name)
  }
}

output "addresses" {
  value = join(",", flatten(libvirt_domain.iscsisrv.*.network_interface.0.addresses))
}
