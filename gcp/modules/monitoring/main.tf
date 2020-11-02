# monitoring deployment in GCP to host Prometheus/Grafana server
# to monitor the various components of the HA SAP cluster

resource "google_compute_disk" "monitoring_data" {
  count = var.monitoring_enabled == true ? 1 : 0
  name  = "${var.common_variables["deployment_name"]}-monitoring-data"
  type  = "pd-standard"
  size  = "20"
  zone  = element(var.compute_zones, 0)
}

resource "google_compute_instance" "monitoring" {
  count        = var.monitoring_enabled == true ? 1 : 0
  name         = "${var.common_variables["deployment_name"]}-monitoring"
  description  = "Monitoring server"
  machine_type = "custom-1-2048"
  zone         = element(var.compute_zones, 0)

  lifecycle {
    create_before_destroy = true
  }

  network_interface {
    subnetwork = var.network_subnet_name
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
      image = var.os_image
    }

    auto_delete = true
  }

  attached_disk {
    source      = element(google_compute_disk.monitoring_data.*.self_link, count.index)
    device_name = element(google_compute_disk.monitoring_data.*.name, count.index)
    mode        = "READ_WRITE"
  }

  metadata = {
    sshKeys = "root:${var.common_variables["public_key"]}"
  }
}

module "monitoring_on_destroy" {
  source               = "../../../generic_modules/on_destroy"
  node_count           = var.monitoring_enabled ? 1 : 0
  instance_ids         = google_compute_instance.monitoring.*.id
  user                 = "root"
  private_key          = var.common_variables["private_key"]
  public_ips           = google_compute_instance.monitoring.*.network_interface.0.access_config.0.nat_ip
  dependencies         = var.on_destroy_dependencies
}
