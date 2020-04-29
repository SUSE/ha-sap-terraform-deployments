# drbd deployment in GCP to host a HA NFS share for SAP Netweaver
# disclaimer: only supports a single NW installation

resource "google_compute_disk" "data" {
  count = var.drbd_count
  name  = "${terraform.workspace}-disk-drbd-${count.index}"
  type  = var.drbd_data_disk_type
  size  = var.drbd_data_disk_size
  zone  = element(var.compute_zones, count.index)
}

# temporary HA solution to create the static routes, eventually this routes must be created by the RA gcp-vpc-move-route
resource "google_compute_route" "drbd-route" {
  name                   = "${terraform.workspace}-drbd-route"
  count                  = var.drbd_count > 0 ? 1 : 0
  dest_range             = "${var.drbd_cluster_vip}/32"
  network                = var.network_name
  next_hop_instance      = google_compute_instance.drbd.0.name
  next_hop_instance_zone = element(var.compute_zones, 0)
  priority               = 1000
}

resource "google_compute_instance" "drbd" {
  machine_type = var.machine_type
  name         = "${terraform.workspace}-drbd0${count.index + 1}"
  count        = var.drbd_count
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
      image = var.drbd_image
    }

    auto_delete = true
  }

  attached_disk {
    source      = element(google_compute_disk.data.*.self_link, count.index)
    device_name = element(google_compute_disk.data.*.name, count.index)
    mode        = "READ_WRITE"
  }

  metadata = {
    sshKeys = "root:${file(var.public_key_location)}"
  }

  service_account {
    scopes = ["compute-rw", "storage-rw", "logging-write", "monitoring-write", "service-control", "service-management"]
  }
}

module "drbd_on_destroy" {
  source               = "../../../generic_modules/on_destroy"
  node_count           = var.drbd_count
  instance_ids         = google_compute_instance.drbd.*.id
  user                 = "root"
  private_key_location = var.private_key_location
  public_ips           = google_compute_instance.drbd.*.network_interface.0.access_config.0.nat_ip
  dependencies         = var.on_destroy_dependencies
}
