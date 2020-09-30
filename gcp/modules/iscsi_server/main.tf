resource "google_compute_disk" "iscsi_data" {
  count = var.iscsi_count
  name  = "${terraform.workspace}-iscsi-data-${count.index + 1}"
  type  = "pd-standard"
  size  = var.iscsi_disk_size
  zone  = element(var.compute_zones, 0)
}

resource "google_compute_instance" "iscsisrv" {
  count        = var.iscsi_count
  name         = "${terraform.workspace}-iscsisrv-${count.index + 1}"
  description  = "iSCSI server"
  machine_type = var.machine_type
  zone         = element(var.compute_zones, 0)

  lifecycle {
    create_before_destroy = true
  }

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
    source      = element(google_compute_disk.iscsi_data.*.self_link, count.index)
    device_name = element(google_compute_disk.iscsi_data.*.name, count.index)
    mode        = "READ_WRITE"
  }

  metadata = {
    sshKeys = "root:${file(var.common_variables["public_key_location"])}"
  }
}

module "iscsi_on_destroy" {
  source               = "../../../generic_modules/on_destroy"
  node_count           = var.iscsi_count
  instance_ids         = google_compute_instance.iscsisrv.*.id
  user                 = "root"
  private_key_location = var.common_variables["private_key_location"]
  public_ips           = google_compute_instance.iscsisrv.*.network_interface.0.access_config.0.nat_ip
  dependencies         = var.on_destroy_dependencies
}
