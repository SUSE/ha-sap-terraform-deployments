# Configure the GCP Provider
provider "google" {
  credentials = file(var.gcp_credentials_file)
  project     = var.project
  region      = var.region
}

data "google_compute_zones" "available" {
  region = var.region
  status = "UP"
}

terraform {
  required_version = ">= 0.12"
}

# Network resources: Network, Subnet
resource "google_compute_network" "ha_network" {
  name                    = "${terraform.workspace}-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "ha_subnet" {
  name          = "${terraform.workspace}-subnet"
  network       = google_compute_network.ha_network.self_link
  region        = var.region
  ip_cidr_range = var.ip_cidr_range
}

# Network firewall rules
resource "google_compute_firewall" "ha_firewall_allow_internal" {
  name          = "${terraform.workspace}-fw-internal"
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
  name    = "${terraform.workspace}-fw-icmp"
  network = google_compute_network.ha_network.name

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "ha_firewall_allow_tcp" {
  name    = "${terraform.workspace}-fw-tcp"
  network = google_compute_network.ha_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "7630", "9668", "9100", "9664", "9090"]
  }
}
