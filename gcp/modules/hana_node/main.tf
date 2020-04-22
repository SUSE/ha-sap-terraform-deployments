# HANA deployment in GCP

# HANA disks configuration information: https://cloud.google.com/solutions/sap/docs/sap-hana-planning-guide#storage_configuration
resource "google_compute_disk" "data" {
  count = var.hana_count
  name  = "${terraform.workspace}-hana-data-${count.index}"
  type  = var.hana_data_disk_type
  size  = var.hana_data_disk_size
  zone  = element(var.compute_zones, count.index)
}

resource "google_compute_disk" "backup" {
  count = var.hana_count
  name  = "${terraform.workspace}-hana-backup-${count.index}"
  type  = var.hana_backup_disk_type
  size  = var.hana_backup_disk_size
  zone  = element(var.compute_zones, count.index)
}

resource "google_compute_disk" "hana-software" {
  count = var.hana_count
  name  = "${terraform.workspace}-hana-software-${count.index}"
  type  = "pd-standard"
  size  = "20"
  zone  = element(var.compute_zones, count.index)
}

# temporary HA solution to create the static routes, eventually this routes must be created by the RA gcp-vpc-move-route
resource "google_compute_route" "hana-route" {
  name                   = "${terraform.workspace}-hana-route"
  count                  = var.hana_count > 0 ? 1 : 0
  dest_range             = "${var.hana_cluster_vip}/32"
  network                = var.network_name
  next_hop_instance      = google_compute_instance.clusternodes.0.name
  next_hop_instance_zone = element(var.compute_zones, 0)
  priority               = 1000
}

resource "google_compute_instance" "clusternodes" {
  machine_type = var.machine_type
  name         = "${terraform.workspace}-hana${var.hana_count > 1 ? "0${count.index + 1}" : ""}"
  count        = var.hana_count
  zone         = element(var.compute_zones, count.index)

  can_ip_forward = true

  network_interface {
    subnetwork = var.network_subnet_name
    network_ip = element(var.host_ips, count.index)

    access_config {
      nat_ip = ""
    }
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }

  boot_disk {
    initialize_params {
      image = var.sles4sap_boot_image
    }

    auto_delete = true
  }

  attached_disk {
    source      = element(google_compute_disk.data.*.self_link, count.index)
    device_name = element(google_compute_disk.data.*.name, count.index)
    mode        = "READ_WRITE"
  }

  attached_disk {
    source      = element(google_compute_disk.backup.*.self_link, count.index)
    device_name = element(google_compute_disk.backup.*.name, count.index)
    mode        = "READ_WRITE"
  }

  attached_disk {
    source      = element(google_compute_disk.hana-software.*.self_link, count.index)
    device_name = element(google_compute_disk.hana-software.*.name, count.index)
    mode        = "READ_WRITE"
  }

  metadata = {
    sshKeys = "root:${file(var.public_key_location)}"
  }

  service_account {
    scopes = ["compute-rw", "storage-rw", "logging-write", "monitoring-write", "service-control", "service-management"]
  }
}

module "hana_on_destroy" {
  source               = "../../../generic_modules/on_destroy"
  node_count           = var.hana_count
  instance_ids         = google_compute_instance.clusternodes.*.id
  user                 = "root"
  private_key_location = var.private_key_location
  public_ips           = google_compute_instance.clusternodes.*.network_interface.0.access_config.0.nat_ip
  dependencies         = var.on_destroy_dependencies
}
