resource "google_compute_network" "ha_network" {
  name                    = "ha-network"
  auto_create_subnetworks = "false"
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "ha_subnet" {
  name          = "ha-subnet"
  description   = "Subnetwork for HA node"
  ip_cidr_range = "${var.ip_cidr_range}"
  network       = "${google_compute_network.ha_network.self_link}"
}

resource "google_compute_firewall" "ha_firewall_allow_internal" {
  name          = "ha-firewall-allow-internal"
  network       = "${google_compute_network.ha_network.name}"
  source_ranges = ["${var.ip_cidr_range}"]

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
  name    = "ha-firewall-allow-icmp"
  network = "${google_compute_network.ha_network.name}"

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "ha_firewall_allow_tcp" {
  name    = "ha-firewall-allow-tcp"
  network = "${google_compute_network.ha_network.name}"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "7630"]
  }
}
