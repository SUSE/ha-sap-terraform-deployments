terraform {
  required_version = ">= 0.12"
}

resource "libvirt_volume" "sbd" {
  name  = "${terraform.workspace}-sbd.raw"
  pool  = var.base_configuration["pool"]
  size  = var.sbd_disk_size
  count = var.sbd_count

  xml {
    xslt = file("modules/sbd/raw.xsl")
  }
}

output "id" {
  value = join(",", libvirt_volume.sbd.*.id)
}
