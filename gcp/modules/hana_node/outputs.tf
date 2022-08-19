output "hana_ip" {
  value = google_compute_instance.clusternodes.*.network_interface.0.network_ip
}

output "hana_public_ip" {
  value = local.bastion_enabled ? [] : google_compute_instance.clusternodes.*.network_interface.0.access_config.0.nat_ip
}

output "hana_name" {
  value = google_compute_instance.clusternodes.*.name
}

output "hana_public_name" {
  value = []
}
