resource "google_compute_disk" "iscsi_data" {
  name  = "iscsi-data"
  type  = "pd-standard"
  size  = "10"
  count = "${var.use_gcp_stonith == "true" ? 0 : 1}"
  zone  = "${element(data.google_compute_zones.available.names, count.index)}"
}

resource "google_compute_disk" "node_data" {
  count = "2"
  name  = "${terraform.workspace}-${var.name}-data-${count.index}"
  type  = "pd-standard"
  size  = "${var.init_type == "all" ? 500 : 50}"
  zone  = "${element(data.google_compute_zones.available.names, count.index)}"
}

resource "google_compute_disk" "backup" {
  count = "2"
  name  = "${terraform.workspace}-${var.name}-backup-${count.index}"
  type  = "pd-standard"
  size  = "${var.init_type == "all" ? var.sap_hana_backup_size : 10}"
  zone  = "${element(data.google_compute_zones.available.names, count.index)}"
}

resource "google_compute_image" "sles_bootable_image" {
  name = "${terraform.workspace}-${var.name}-sles"

  raw_disk {
    source = "${var.storage_url}/${var.images_path_bucket}/${var.sles_os_image_file}"
  }
}

resource "google_compute_image" "sles4sap_bootable_image" {
  name = "${terraform.workspace}-${var.name}-sles4sap"

  raw_disk {
    source = "${var.storage_url}/${var.images_path_bucket}/${var.sles4sap_os_image_file}"
  }
}
