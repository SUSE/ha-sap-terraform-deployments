output "monitoring_ip" {
  value = join("", google_compute_instance.monitoring.*.network_interface.0.network_ip)
}

output "monitoring_public_ip" {
  value = local.bastion_enabled ? "" : join("", google_compute_instance.monitoring.*.network_interface.0.access_config.0.nat_ip)
}

output "monitoring_name" {
  value = join("", google_compute_instance.monitoring.*.name)
}

output "monitoring_public_name" {
  value = ""
}
