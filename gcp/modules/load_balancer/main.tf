# GCP load balancer resource
# Based on: https://cloud.google.com/solutions/sap/docs/sap-hana-ha-vip-migration-sles
# And: https://cloud.google.com/solutions/sap/docs/sap-hana-ha-config-sles

resource "google_compute_health_check" "health-check" {
  name = "${var.name}-health-check"

  timeout_sec         = 10
  check_interval_sec  = 10
  unhealthy_threshold = 2
  healthy_threshold   = 2

  tcp_health_check {
    port = var.tcp_health_check_port
  }
}

# More information about the load balancer firewall
# https://cloud.google.com/load-balancing/docs/health-checks#fw-rule
resource "google_compute_firewall" "load-balancer-firewall" {
  name          = "${var.name}-load-balancer-firewall"
  network       = var.network_name
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = var.target_tags

  allow {
    protocol = "tcp"
    ports    = [var.tcp_health_check_port]
  }
}

resource "google_compute_region_backend_service" "backend-service" {
  name                  = "${var.name}-backend-service"
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_health_check.health-check.*.id[0]]

  backend {
    group = var.primary_node_group
  }

  backend {
    group    = var.secondary_node_group
    failover = true
  }

  failover_policy {
    disable_connection_drain_on_failover = true
    drop_traffic_if_unhealthy            = true
    failover_ratio                       = 1
  }
}

resource "google_compute_forwarding_rule" "load-balancer-forwarding-rule" {
  name                  = "${var.name}-load-balancer-forwarding-rule"
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  subnetwork            = var.network_subnet_name
  ip_address            = var.ip_address
  backend_service       = google_compute_region_backend_service.backend-service.id
  all_ports             = true
}
