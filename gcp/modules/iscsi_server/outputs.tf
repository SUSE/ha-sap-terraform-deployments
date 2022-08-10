output "iscsi_ip" {
  value = join("", google_compute_instance.iscsisrv.*.network_interface.0.network_ip)
}

output "iscsi_public_ip" {
  value = local.bastion_enabled ? "" : join("", google_compute_instance.iscsisrv.*.network_interface.0.access_config.0.nat_ip)
}

output "iscsi_name" {
  value = join("", google_compute_instance.iscsisrv.*.name)
}

output "iscsi_public_name" {
  value = []
}
