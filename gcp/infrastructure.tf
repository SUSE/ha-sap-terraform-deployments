# Configure the GCP Provider
provider "google" {
  version     = "~> 3.43.0"
  credentials = file(var.gcp_credentials_file)
  project     = var.project
  region      = var.region
}

terraform {
  required_version = ">= 0.13"
}

data "google_compute_zones" "available" {
  region = var.region
  status = "UP"
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

  create_firewall = ! var.bastion_enabled && var.create_firewall_rules ? 1 : 0
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
  count   = local.create_firewall
  name    = "${local.deployment_name}-fw-icmp"
  network = local.vpc_name

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "ha_firewall_allow_tcp" {
  count   = local.create_firewall
  name    = "${local.deployment_name}-fw-tcp"
  network = local.vpc_name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3000", "7630", "9668", "9100", "9664", "9090", "9680"]
  }
}

# Bastion

module "bastion" {
  source             = "./modules/bastion"
  common_variables   = module.common_variables.configuration
  name               = var.bastion_name
  network_domain     = var.bastion_network_domain == "" ? var.network_domain : var.bastion_network_domain
  region             = var.region
  os_image           = local.bastion_os_image
  vm_size            = "custom-1-2048"
  compute_zones      = data.google_compute_zones.available.names
  network_link       = local.network_link
  snet_address_range = cidrsubnet(cidrsubnet(local.subnet_address_range, -4, 0), 4, 2)
}

# Create NAT service to provide external connection to the VMs without public ip address
# This is just a basic NAT, more advanced configuration is possible
# Based on: https://cloud.google.com/solutions/sap/docs/sap-hana-ha-dm-deployment-sles#setting-up-a-nat-gateway
resource "google_compute_router" "router" {
  count   = var.bastion_enabled ? 1 : 0
  name    = "${local.deployment_name}-router"
  region  = var.region
  network = local.network_link
}

resource "google_compute_router_nat" "nat" {
  count  = var.bastion_enabled ? 1 : 0
  name   = "${local.deployment_name}-nat"
  router = google_compute_router.router.*.name[0]
  region = var.region

  nat_ip_allocate_option = "AUTO_ONLY"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.ha_subnet.*.self_link[0]
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  min_ports_per_vm = var.bastion_nat_min_ports_per_vm
}
