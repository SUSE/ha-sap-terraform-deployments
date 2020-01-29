resource "google_compute_network" "ha_network" {
  name                    = "${terraform.workspace}-${var.name}-network"
  auto_create_subnetworks = "false"
}

# temporary HA solution to create the static routes, eventually this routes must be created by the RA gcp-vpc-move-route
resource "google_compute_route" "hana-route" {
  name                   = "hana-route"
  dest_range             = "${var.hana_cluster_vip}/32"
  network                = google_compute_network.ha_network.name
  next_hop_instance      = google_compute_instance.clusternodes.0.name
  next_hop_instance_zone = element(data.google_compute_zones.available.names, 0)
  priority               = 1000
}

resource "google_compute_subnetwork" "ha_subnet" {
  name          = "${terraform.workspace}-${var.name}-subnet"
  network       = google_compute_network.ha_network.self_link
  region        = var.region
  ip_cidr_range = var.ip_cidr_range
}

resource "google_compute_firewall" "ha_firewall_allow_internal" {
  name          = "${terraform.workspace}-${var.name}-fw-internal"
  network       = google_compute_network.ha_network.name
  source_ranges = [var.ip_cidr_range]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
}

resource "google_compute_firewall" "ha_firewall_allow_icmp" {
  name    = "${terraform.workspace}-${var.name}-fw-icmp"
  network = google_compute_network.ha_network.name

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "ha_firewall_allow_tcp" {
  name    = "${terraform.workspace}-${var.name}-fw-tcp"
  network = google_compute_network.ha_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "7630", "8001", "9100", "9002", "9090"]
  }
}
