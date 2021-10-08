resource "libvirt_volume" "shared_disk" {
  name  = "${var.common_variables["deployment_name"]}-${var.name}.raw"
  pool  = var.pool
  size  = var.shared_disk_size
  count = var.shared_disk_count

  xml {
    xslt = file("modules/shared_disk/raw.xsl")
  }
}

output "id" {
  value = join(",", libvirt_volume.shared_disk.*.id)
}
