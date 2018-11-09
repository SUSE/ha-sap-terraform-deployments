# Outputs: Public IP address and port where the service will be listening on

output "cluster_nodes_ip" {
  value = "${google_compute_instance.clusternodes.*.network_interface.0.access_config.0.assigned_nat_ip}"
}
