# netweaver deployment in GCP
# official documentation: https://cloud.google.com/solutions/sap/docs/netweaver-ha-planning-guide

locals {
  create_ha_infra = var.netweaver_count > 1 && var.ha_enabled ? 1 : 0
}

resource "google_compute_disk" "netweaver-software" {
  count = var.netweaver_count
  name  = "${terraform.workspace}-nw-installation-sw-${count.index}"
  type  = "pd-standard"
  size  = 60
  zone  = element(var.compute_zones, count.index)
}

# Don't remove the routes! Even though the RA gcp-vpc-move-route creates them, if they are not created here, the terraform destroy cannot work as it will find new route names
resource "google_compute_route" "nw-ascs-route" {
  name                   = "${terraform.workspace}-nw-ascs-route"
  count                  = local.create_ha_infra
  dest_range             = "${element(var.virtual_host_ips, 0)}/32"
  network                = var.network_name
  next_hop_instance      = google_compute_instance.netweaver.0.name
  next_hop_instance_zone = element(var.compute_zones, 0)
  priority               = 1000
}

resource "google_compute_route" "nw-ers-route" {
  name                   = "${terraform.workspace}-nw-ers-route"
  count                  = local.create_ha_infra
  dest_range             = "${element(var.virtual_host_ips, 1)}/32"
  network                = var.network_name
  next_hop_instance      = google_compute_instance.netweaver.1.name
  next_hop_instance_zone = element(var.compute_zones, 1)
  priority               = 1000
}

resource "google_compute_instance" "netweaver" {
  machine_type = var.machine_type
  name         = "${terraform.workspace}-netweaver0${count.index + 1}"
  count        = var.netweaver_count
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
    source      = element(google_compute_disk.netweaver-software.*.self_link, count.index)
    device_name = element(google_compute_disk.netweaver-software.*.name, count.index)
    mode        = "READ_WRITE"
  }

  metadata = {
    sshKeys = "root:${file(var.common_variables["public_key_location"])}"
  }

  service_account {
    scopes = ["compute-rw", "storage-rw", "logging-write", "monitoring-write", "service-control", "service-management"]
  }
}

module "netweaver_on_destroy" {
  source               = "../../../generic_modules/on_destroy"
  node_count           = var.netweaver_count
  instance_ids         = google_compute_instance.netweaver.*.id
  user                 = "root"
  private_key_location = var.common_variables["private_key_location"]
  public_ips           = google_compute_instance.netweaver.*.network_interface.0.access_config.0.nat_ip
  dependencies         = var.on_destroy_dependencies
}
