resource "google_compute_disk" "node_data" {
  count = "${var.node_count}"
  name  = "node-data-${count.index}"
  type  = "pd-standard"
  size  = "1500"
}

resource "google_compute_disk" "backup" {
  count = "${var.node_count}"
  name  = "node-backup-${count.index}"
  type  = "pd-standard"
  size  = "100"
}

resource "google_compute_image" "sles4sap_bootable_image" {
  name = "sles4sap-${var.sle_version}-v${var.date_of_the_day}"

  raw_disk {
    source = "${var.storage_url}/${var.images_path_bucket}/${var.sles4sap_os_image_file}"
  }
}
