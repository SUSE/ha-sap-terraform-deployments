resource "google_compute_instance" "iscsisrv" {
  name         = "${terraform.workspace}-iscsisrv"
  description  = "iSCSI server"
  machine_type = var.machine_type_iscsi_server
  zone         = element(data.google_compute_zones.available.names, 0)

  lifecycle {
    create_before_destroy = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.ha_subnet.name
    network_ip = var.iscsi_ip

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
      image = var.iscsi_server_boot_image
    }

    auto_delete = true
  }

  attached_disk {
    source      = google_compute_disk.iscsi_data.self_link
    device_name = google_compute_disk.iscsi_data.name
    mode        = "READ_WRITE"
  }

  metadata = {
    sshKeys = "root:${file(var.public_key_location)}"
  }
}

module "iscsi_on_destroy" {
  source               = "../generic_modules/on_destroy"
  node_count           = 1
  instance_ids         = google_compute_instance.iscsisrv.*.id
  user                 = "root"
  private_key_location = var.private_key_location
  public_ips           = google_compute_instance.iscsisrv.*.network_interface.0.access_config.0.nat_ip
  dependencies         = [google_compute_firewall.ha_firewall_allow_tcp]
}

resource "google_compute_instance" "clusternodes" {
  machine_type = var.machine_type
  name         = "${terraform.workspace}-${var.name}${var.ninstances > 1 ? "0${count.index + 1}" : ""}"
  count        = var.ninstances
  zone         = element(data.google_compute_zones.available.names, count.index)

  can_ip_forward = true

  network_interface {
    subnetwork = google_compute_subnetwork.ha_subnet.name
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
  source               = "../generic_modules/on_destroy"
  node_count           = var.ninstances
  instance_ids         = google_compute_instance.clusternodes.*.id
  user                 = "root"
  private_key_location = var.private_key_location
  public_ips           = google_compute_instance.clusternodes.*.network_interface.0.access_config.0.nat_ip
  dependencies         = [google_compute_firewall.ha_firewall_allow_tcp]
}

resource "google_compute_instance" "monitoring" {
  count        = var.monitoring_enabled == true ? 1 : 0
  name         = "${terraform.workspace}-monitoring"
  description  = "Monitoring server"
  machine_type = "custom-1-2048"
  zone         = element(data.google_compute_zones.available.names, 0)

  lifecycle {
    create_before_destroy = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.ha_subnet.name
    network_ip = var.monitoring_srv_ip

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
    source      = element(google_compute_disk.monitoring_data.*.self_link, count.index)
    device_name = element(google_compute_disk.monitoring_data.*.name, count.index)
    mode        = "READ_WRITE"
  }

  metadata = {
    sshKeys = "root:${file(var.public_key_location)}"
  }
}

module "monitoring_on_destroy" {
  source               = "../generic_modules/on_destroy"
  node_count           = var.monitoring_enabled ? 1 : 0
  instance_ids         = google_compute_instance.monitoring.*.id
  user                 = "root"
  private_key_location = var.private_key_location
  public_ips           = google_compute_instance.monitoring.*.network_interface.0.access_config.0.nat_ip
  dependencies         = [google_compute_firewall.ha_firewall_allow_tcp]
}
