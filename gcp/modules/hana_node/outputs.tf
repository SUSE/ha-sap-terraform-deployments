output "cluster_nodes_ip" {
  value = google_compute_instance.clusternodes.*.network_interface.0.network_ip
}

output "cluster_nodes_public_ip" {
  value = google_compute_instance.clusternodes.*.network_interface.0.access_config.0.nat_ip
}

output "cluster_nodes_name" {
  value = google_compute_instance.clusternodes.*.name
}

output "cluster_nodes_public_name" {
  value = []
}