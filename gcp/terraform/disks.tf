resource "google_compute_disk" "node_data" {
  count = "2"
  name  = "${terraform.workspace}-${var.name}-data-${count.index}"
  type  = "pd-standard"
  size  = "1500"
  zone  = "${element(data.google_compute_zones.available.names, count.index)}"
}

resource "google_compute_disk" "backup" {
  count = "2"
  name  = "${terraform.workspace}-${var.name}-backup-${count.index}"
  type  = "pd-standard"
  size  = "100"
  zone  = "${element(data.google_compute_zones.available.names, count.index)}"
}

resource "google_compute_image" "sles4sap_bootable_image" {
  name = "${terraform.workspace}-${var.name}-sles4sap"

  raw_disk {
    source = "${var.storage_url}/${var.images_path_bucket}/${var.sles4sap_os_image_file}"
  }
}
