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

resource "google_compute_firewall" "ha_firewall_allow_ssh" {
  name    = "ha-firewall-allow-ssh"
  network = "${google_compute_network.ha_network.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "ha_firewall_allow_http" {
  name    = "ha-firewall-allow-http"
  network = "${google_compute_network.ha_network.name}"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "ha_firewall_allow_https" {
  name    = "ha-firewall-allow-https"
  network = "${google_compute_network.ha_network.name}"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

resource "google_compute_firewall" "ha_firewall_allow_hawk" {
  name    = "ha-firewall-allow-hawk"
  network = "${google_compute_network.ha_network.name}"

  allow {
    protocol = "tcp"
    ports    = ["7630"]
  }
}

# data "google_dns_managed_zone" "env_dns_zone" {
#   name     = "env-dns-zone"
# }


# resource "google_dns_record_set" "ha_dns" {
#   name = "ha_dns.${data.google_dns_managed_zone.env_dns_zone.dns_name}"
#   name = "ha-dns"
#   type = "A"
#   ttl  = 300
# 
#   managed_zone = "${data.google_dns_managed_zone.env_dns_zone.name}"
# 
#   rrdatas = ["${data.google_compute_address.ha_nodes.network_interface.0.access_config.0.assigned_nat_ip}"]
# }

