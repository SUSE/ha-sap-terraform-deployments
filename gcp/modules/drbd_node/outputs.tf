output "drbd_ip" {
  value = google_compute_instance.drbd.*.network_interface.0.network_ip
}

output "drbd_public_ip" {
  value = local.bastion_enabled ? [] : google_compute_instance.drbd.*.network_interface.0.access_config.0.nat_ip
}

output "drbd_name" {
  value = google_compute_instance.drbd.*.name
}

output "drbd_public_name" {
  value = []
}
