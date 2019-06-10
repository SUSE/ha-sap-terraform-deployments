# Outputs: IP address and port where the service will be listening on

output "cluster_nodes_ip" {
  value = "${module.hana_node.addresses["addresses"]}"
}

output "cluster_nodes_id" {
  value = "${module.hana_node.configuration["id"]}"
}

output "cluster_nodes_hostname" {
  value = "${module.hana_node.configuration["hostname"]}"
}
