# netweaver deployment in GCP
# official documentation: https://cloud.google.com/solutions/sap/docs/netweaver-ha-planning-guide

locals {
  vm_count        = var.xscs_server_count + var.app_server_count
  create_ha_infra = local.vm_count > 1 && var.common_variables["hana"]["ha_enabled"] ? 1 : 0
  bastion_enabled        = var.common_variables["bastion_enabled"]
  provisioning_addresses = local.bastion_enabled ? google_compute_instance.netweaver.*.network_interface.0.network_ip : google_compute_instance.netweaver.*.network_interface.0.access_config.0.nat_ip
}

resource "google_compute_disk" "netweaver-software" {
  count = local.vm_count
  name  = "${var.common_variables["deployment_name"]}-nw-installation-sw-${count.index}"
  type  = "pd-standard"
  size  = 60
  zone  = element(var.compute_zones, count.index)
}

# Don't remove the routes! Even though the RA gcp-vpc-move-route creates them, if they are not created here, the terraform destroy cannot work as it will find new route names
resource "google_compute_route" "nw-ascs-route" {
  name                   = "${var.common_variables["deployment_name"]}-nw-ascs-route"
  count                  = local.create_ha_infra
  dest_range             = "${element(var.virtual_host_ips, 0)}/32"
  network                = var.network_name
  next_hop_instance      = google_compute_instance.netweaver.0.name
  next_hop_instance_zone = element(var.compute_zones, 0)
  priority               = 1000
}

resource "google_compute_route" "nw-ers-route" {
  name                   = "${var.common_variables["deployment_name"]}-nw-ers-route"
  count                  = local.create_ha_infra
  dest_range             = "${element(var.virtual_host_ips, 1)}/32"
  network                = var.network_name
  next_hop_instance      = google_compute_instance.netweaver.1.name
  next_hop_instance_zone = element(var.compute_zones, 1)
  priority               = 1000
}

resource "google_compute_instance" "netweaver" {
  machine_type = var.machine_type
  name         = "${var.common_variables["deployment_name"]}-netweaver0${count.index + 1}"
  count        = local.vm_count
  zone         = element(var.compute_zones, count.index)

  can_ip_forward = true

  network_interface {
    subnetwork = var.network_subnet_name
    network_ip = element(var.host_ips, count.index)

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
    source      = element(google_compute_disk.netweaver-software.*.self_link, count.index)
    device_name = element(google_compute_disk.netweaver-software.*.name, count.index)
    mode        = "READ_WRITE"
  }

  metadata = {
    sshKeys = "${var.common_variables["authorized_user"]}:${var.common_variables["public_key"]}"
  }

  service_account {
    scopes = ["compute-rw", "storage-rw", "logging-write", "monitoring-write", "service-control", "service-management"]
  }
}

module "netweaver_on_destroy" {
  source               = "../../../generic_modules/on_destroy"
  node_count           = local.vm_count
  instance_ids         = google_compute_instance.netweaver.*.id
  user                 = var.common_variables["authorized_user"]
  private_key          = var.common_variables["private_key"]
  bastion_host         = var.bastion_host
  bastion_private_key  = var.common_variables["bastion_private_key"]
  public_ips           = local.provisioning_addresses
  dependencies         = var.on_destroy_dependencies
}
