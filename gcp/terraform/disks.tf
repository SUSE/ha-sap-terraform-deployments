resource "google_compute_disk" "iscsi_data" {
  name = "iscsi-data"
  type = "pd-standard"
  size = "10"
}

resource "google_compute_disk" "node_data" {
  count = "${var.node_count}"
  name  = "node-data-${count.index}"
  type  = "pd-standard"
  size  = "50"
}

resource "google_compute_image" "sles_bootable_image" {
  name = "sles-${var.sle_version}-v${var.date_of_the_day}"

  raw_disk {
    source = "${var.storage_url}/${var.images_path_bucket}/${var.sles_os_image_file}"
  }
}

resource "google_compute_image" "sles4sap_bootable_image" {
  name = "sles4sap-${var.sle_version}-v${var.date_of_the_day}"

  raw_disk {
    source = "${var.storage_url}/${var.images_path_bucket}/${var.sles4sap_os_image_file}"
  }
}
