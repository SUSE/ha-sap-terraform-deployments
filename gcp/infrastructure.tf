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

data "google_compute_subnetwork" "current-subnet" {
  count  = var.ip_cidr_range == "" ? 1 : 0
  name   = var.subnet_name
  region = var.region
}

locals {
  deployment_name = var.deployment_name != "" ? var.deployment_name : terraform.workspace

  network_link = var.vpc_name == "" ? google_compute_network.ha_network.0.self_link : format(
  "https://www.googleapis.com/compute/v1/projects/%s/global/networks/%s", var.project, var.vpc_name)
  vpc_name             = var.vpc_name == "" ? google_compute_network.ha_network.0.name : var.vpc_name
  subnet_name          = var.subnet_name == "" ? google_compute_subnetwork.ha_subnet.0.name : var.subnet_name
  subnet_address_range = var.subnet_name == "" ? var.ip_cidr_range : (var.ip_cidr_range == "" ? data.google_compute_subnetwork.current-subnet.0.ip_cidr_range : var.ip_cidr_range)
}

# Network resources: Network, Subnet
resource "google_compute_network" "ha_network" {
  count                   = var.vpc_name == "" ? 1 : 0
  name                    = "${local.deployment_name}-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "ha_subnet" {
  count         = var.subnet_name == "" ? 1 : 0
  name          = "${local.deployment_name}-subnet"
  network       = local.network_link
  region        = var.region
  ip_cidr_range = local.subnet_address_range
}

# Network firewall rules
resource "google_compute_firewall" "ha_firewall_allow_internal" {
  name          = "${local.deployment_name}-fw-internal"
  network       = local.vpc_name
  source_ranges = [local.subnet_address_range]

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
  count   = var.create_firewall_rules ? 1 : 0
  name    = "${local.deployment_name}-fw-icmp"
  network = local.vpc_name

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "ha_firewall_allow_tcp" {
  count   = var.create_firewall_rules ? 1 : 0
  name    = "${local.deployment_name}-fw-tcp"
  network = local.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3000", "7630", "9668", "9100", "9664", "9090"]
  }
}
