resource "google_compute_network" "ha_network" {
  name                    = "${terraform.workspace}-${var.name}-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "ha_subnet" {
  name          = "${terraform.workspace}-${var.name}-subnet"
  network       = google_compute_network.ha_network.self_link
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
    ports    = ["22", "80", "443", "7630", "9668", "9100", "9664", "9090"]
  }
}

