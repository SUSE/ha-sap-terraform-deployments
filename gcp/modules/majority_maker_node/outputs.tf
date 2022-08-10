output "majority_maker_ip" {
  value = google_compute_instance.majority_maker.*.network_interface.0.network_ip
}

output "majority_maker_public_ip" {
  value = local.bastion_enabled ? [] : google_compute_instance.majority_maker.*.network_interface.0.access_config.0.nat_ip
}

output "majority_maker_name" {
  value = google_compute_instance.majority_maker.*.name
}

output "majority_maker_public_name" {
  value = []
}
