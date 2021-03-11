output "netweaver_ip" {
  value = google_compute_instance.netweaver.*.network_interface.0.network_ip
}

output "netweaver_public_ip" {
  value = local.bastion_enabled ? [] : google_compute_instance.netweaver.*.network_interface.0.access_config.0.nat_ip
}

output "netweaver_name" {
  value = google_compute_instance.netweaver.*.name
}

output "netweaver_public_name" {
  value = []
}
