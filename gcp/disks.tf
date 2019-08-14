resource "google_compute_disk" "iscsi_data" {
  name = "${terraform.workspace}-${var.name}-iscsi-data"
  type = "pd-standard"
  size = "10"
  zone = element(data.google_compute_zones.available.names, 1)
}

resource "google_compute_disk" "node_data" {
  count = "2"
  name  = "${terraform.workspace}-${var.name}-data-${count.index}"
  type  = "pd-standard"
  size  = var.init_type == "all" ? 60 : 30
  zone  = element(data.google_compute_zones.available.names, count.index)
}

resource "google_compute_disk" "node_data2" {
  count = "2"
  name  = "${terraform.workspace}-${var.name}-backup-${count.index}"
  type  = "pd-standard"
  size  = "20"
  zone  = element(data.google_compute_zones.available.names, count.index)
}

