resource "google_compute_disk" "iscsi_data" {
  name = "${terraform.workspace}-iscsi-data"
  type = "pd-standard"
  size = "10"
  zone = element(var.compute_zones, 0)
}

resource "google_compute_instance" "iscsisrv" {
  name         = "${terraform.workspace}-iscsisrv"
  description  = "iSCSI server"
  machine_type = var.machine_type_iscsi_server
  zone         = element(var.compute_zones, 0)

  lifecycle {
    create_before_destroy = true
  }

  network_interface {
    subnetwork = var.network_subnet_name
    network_ip = var.iscsi_srv_ip

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
  source               = "../../../generic_modules/on_destroy"
  node_count           = 1
  instance_ids         = google_compute_instance.iscsisrv.*.id
  user                 = "root"
  private_key_location = var.private_key_location
  public_ips           = google_compute_instance.iscsisrv.*.network_interface.0.access_config.0.nat_ip
  dependencies         = var.on_destroy_dependencies
}
