terraform {
  required_version = "~> 0.11.7"
}

resource "libvirt_volume" "iscsi_image_disk" {
  name   = "${terraform.workspace}-iscsi-disk"
  source = "${var.iscsi_image}"
  pool   = "${var.base_configuration["pool"]}"
  count = "${var.count}"
}

resource "libvirt_volume" "iscsi_dev_disk" {
  name  = "${terraform.workspace}-iscsi-dev"
  pool  = "${var.base_configuration["pool"]}"
  size  = "10000000000" # 10GB
  count = "${var.count}"
}

resource "libvirt_domain" "iscsisrv" {
  name       = "${terraform.workspace}-iscsi"
  memory     = "${var.memory}"
  vcpu       = "${var.vcpu}"
  running    = "${var.running}"
  count      = "${var.count}"
  qemu_agent = true

  disk {
    volume_id = "${libvirt_volume.iscsi_image_disk.id}"
  }

  disk {
    volume_id = "${libvirt_volume.iscsi_dev_disk.id}"
  }

  network_interface {
    network_name   = "${var.base_configuration["network_name"]}"
    bridge         = "${var.base_configuration["bridge"]}"
    mac            = "${var.mac}"
    wait_for_lease = true
  }

  network_interface {
    network_id   = "${var.base_configuration["isolated_network_id"]}"
    mac            = "${var.mac}"
    addresses      = ["${var.iscsi_srv_ip}"]
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

output "configuration" {
  value {
    id       = "${join(",", libvirt_domain.iscsisrv.*.id)}"
    hostname = "${join(",", libvirt_domain.iscsisrv.*.name)}"
  }
}

output "addresses" {
  // Returning only the addresses is not possible right now. Will be available in terraform 12
  // https://bradcod.es/post/terraform-conditional-outputs-in-modules/
  value = "${libvirt_domain.iscsisrv.*.network_interface}"
}
