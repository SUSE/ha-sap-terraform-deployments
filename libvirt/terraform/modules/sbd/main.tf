resource "libvirt_volume" "sbd" {
  name = "${var.base_configuration["name_prefix"]}-sbd"
  pool = "${var.base_configuration["pool"]}"
  size = "${var.sbd_disk_size}"
}

output "id" {
  value = "${libvirt_volume.sbd.id}"
}
