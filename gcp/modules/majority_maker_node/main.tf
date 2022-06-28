# HANA deployment in GCP

locals {
  bastion_enabled        = var.common_variables["bastion_enabled"]
  provisioning_addresses = local.bastion_enabled ? google_compute_instance.majority_maker.*.network_interface.0.network_ip : google_compute_instance.majority_maker.*.network_interface.0.access_config.0.nat_ip
  hostname               = var.common_variables["deployment_name_in_hostname"] ? format("%s-%s", var.common_variables["deployment_name"], var.name) : var.name
}

resource "google_compute_instance" "majority_maker" {
  count        = var.node_count
  machine_type = var.machine_type
  name         = "${var.common_variables["deployment_name"]}-${var.name}mm"
  zone         = element(var.compute_zones, 2)

  can_ip_forward = true

  network_interface {
    subnetwork = var.network_subnet_name
    network_ip = var.majority_maker_ip

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
      size  = 60
    }

    auto_delete = true
  }

  metadata = {
    sshKeys = "${var.common_variables["authorized_user"]}:${var.common_variables["public_key"]}"
  }

  service_account {
    scopes = ["compute-rw", "storage-rw", "logging-write", "monitoring-write", "service-control", "service-management"]
  }

  tags = ["hana-group"]
}

module "hana_on_destroy" {
  source              = "../../../generic_modules/on_destroy"
  node_count          = var.node_count
  instance_ids        = google_compute_instance.majority_maker.*.id
  user                = var.common_variables["authorized_user"]
  private_key         = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips          = local.provisioning_addresses
  dependencies        = var.on_destroy_dependencies
}
