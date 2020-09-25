# HANA deployment in GCP

locals {
  create_ha_infra = var.hana_count > 1 && var.ha_enabled ? 1 : 0
}

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

# Don't remove the routes! Even though the RA gcp-vpc-move-route creates them, if they are not created here, the terraform destroy cannot work as it will find new route names
resource "google_compute_route" "hana-route" {
  name                   = "${terraform.workspace}-hana-route"
  count                  = local.create_ha_infra
  dest_range             = "${var.hana_cluster_vip}/32"
  network                = var.network_name
  next_hop_instance      = google_compute_instance.clusternodes.0.name
  next_hop_instance_zone = element(var.compute_zones, 0)
  priority               = 1000
}

# Route for Active/Active setup
resource "google_compute_route" "hana-route-secondary" {
  name                   = "${terraform.workspace}-hana-route-secondary"
  count                  = local.create_ha_infra == 1 && var.hana_cluster_vip_secondary != "" ? 1 : 0
  dest_range             = "${var.hana_cluster_vip_secondary}/32"
  network                = var.network_name
  next_hop_instance      = google_compute_instance.clusternodes.1.name
  next_hop_instance_zone = element(var.compute_zones, 1)
  priority               = 1000
}

resource "google_compute_instance" "clusternodes" {
  machine_type = var.machine_type
  name         = "${terraform.workspace}-hana0${count.index + 1}"
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
      image = var.os_image
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
    sshKeys = "root:${file(var.common_variables["public_key_location"])}"
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
  private_key_location = var.common_variables["private_key_location"]
  public_ips           = google_compute_instance.clusternodes.*.network_interface.0.access_config.0.nat_ip
  dependencies         = var.on_destroy_dependencies
}
