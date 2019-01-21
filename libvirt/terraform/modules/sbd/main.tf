resource "libvirt_volume" "sbd" {
  name = "${var.base_configuration["name_prefix"]}-sbd.raw"
  pool = "${var.base_configuration["pool"]}"
  size = "${var.sbd_disk_size}"

  xml {
    xslt = "${file("modules/sbd/raw.xsl")}"
  }
}

output "id" {
  value = "${libvirt_volume.sbd.id}"
}
