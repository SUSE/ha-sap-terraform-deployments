resource "google_compute_disk" "iscsi_data" {
  name = "${terraform.workspace}-${var.name}-iscsi-data"
  type = "pd-standard"
  size = "10"
  zone = element(data.google_compute_zones.available.names, 0)
}

# HANA disks configuration information: https://cloud.google.com/solutions/sap/docs/sap-hana-planning-guide#storage_configuration

resource "google_compute_disk" "data" {
  count = var.ninstances
  name  = "${terraform.workspace}-${var.name}-data-${count.index}"
  type  = var.hana_data_disk_type
  size  = var.hana_data_disk_size
  zone  = element(data.google_compute_zones.available.names, count.index)
}

resource "google_compute_disk" "backup" {
  count = var.ninstances
  name  = "${terraform.workspace}-${var.name}-backup-${count.index}"
  type  = var.hana_backup_disk_type
  size  = var.hana_backup_disk_size
  zone  = element(data.google_compute_zones.available.names, count.index)
}

resource "google_compute_disk" "hana-software" {
  count = var.ninstances
  name  = "${terraform.workspace}-${var.name}-hana-software-${count.index}"
  type  = "pd-standard"
  size  = "20"
  zone  = element(data.google_compute_zones.available.names, count.index)
}
