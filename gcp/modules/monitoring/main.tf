# monitoring deployment in GCP to host Prometheus/Grafana server
# to monitor the various components of the HA SAP cluster

locals {
  bastion_enabled        = var.common_variables["bastion_enabled"]
  provisioning_addresses = local.bastion_enabled ? google_compute_instance.monitoring.*.network_interface.0.network_ip : google_compute_instance.monitoring.*.network_interface.0.access_config.0.nat_ip
  hostname               = var.common_variables["deployment_name_in_hostname"] ? format("%s-%s", var.common_variables["deployment_name"], var.name) : var.name
}

resource "google_compute_disk" "monitoring_data" {
  count = var.monitoring_enabled == true ? 1 : 0
  name  = "${var.common_variables["deployment_name"]}-monitoring-data"
  type  = "pd-standard"
  size  = "20"
  zone  = element(var.compute_zones, 0)
}

resource "google_compute_instance" "monitoring" {
  count        = var.monitoring_enabled == true ? 1 : 0
  name         = "${var.common_variables["deployment_name"]}-${var.name}"
  description  = "Monitoring server"
  machine_type = "custom-1-2048"
  zone         = element(var.compute_zones, 0)

  can_ip_forward = true

  network_interface {
    subnetwork = var.network_subnet_name
    network_ip = var.monitoring_srv_ip

    # Set public IP address. Only if the bastion is not used
    dynamic "access_config" {
      for_each = local.bastion_enabled ? [] : [1]
      content {
        nat_ip = ""
      }
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
    sshKeys = "${var.common_variables["authorized_user"]}:${var.common_variables["public_key"]}"
  }

  service_account {
    scopes = ["compute-rw", "storage-rw", "logging-write", "monitoring-write", "service-control", "service-management"]
  }
}

module "monitoring_on_destroy" {
  source              = "../../../generic_modules/on_destroy"
  node_count          = var.monitoring_enabled ? 1 : 0
  instance_ids        = google_compute_instance.monitoring.*.id
  user                = var.common_variables["authorized_user"]
  private_key         = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips          = local.provisioning_addresses
  dependencies        = var.on_destroy_dependencies
}
