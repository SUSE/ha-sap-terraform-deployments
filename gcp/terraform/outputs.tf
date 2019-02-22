# Outputs: Public IP address where the service will be listening on

output "iscsisrv_ip" {
  value = "${google_compute_instance.iscsisrv.network_interface.0.access_config.0.nat_ip}"
}

output "cluster_nodes_ip" {
  value = "${google_compute_instance.clusternodes.*.network_interface.0.access_config.0.nat_ip}"
}
