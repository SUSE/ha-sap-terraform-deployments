resource "google_compute_instance" "iscsisrv" {
  name         = "${terraform.workspace}-iscsisrv"
  description  = "iSCSI server"
  machine_type = var.machine_type_iscsi_server
  zone         = element(data.google_compute_zones.available.names, 1)

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
    source      = element(google_compute_disk.node_data.*.self_link, count.index)
    device_name = element(google_compute_disk.node_data.*.name, count.index)
    mode        = "READ_WRITE"
  }

  attached_disk {
    source      = element(google_compute_disk.node_data2.*.self_link, count.index)
    device_name = element(google_compute_disk.node_data2.*.name, count.index)
    mode        = "READ_WRITE"
  }

  metadata = {
    sshKeys = "root:${file(var.public_key_location)}"
  }

  service_account {
    scopes = ["compute-rw", "storage-rw", "logging-write", "monitoring-write", "service-control", "service-management"]
  }
}

