output "iscsisrv_ip" {
  value = join("", google_compute_instance.iscsisrv.network_interface.*.network_ip)
}

output "iscsisrv_public_ip" {
  value = join("", google_compute_instance.iscsisrv.network_interface.*.access_config.0.nat_ip)
}

output "iscsisrv_name" {
  value = join("", google_compute_instance.iscsisrv.*.name)
}

output "iscsisrv_public_name" {
  value = []
}
