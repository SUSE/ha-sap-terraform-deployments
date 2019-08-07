# Outputs: IP address and port where the service will be listening on

output "cluster_nodes_ip" {
  value = "${module.netweaver_node.addresses["addresses"]}"
}

output "cluster_nodes_id" {
  value = "${module.netweaver_node.configuration["id"]}"
}

output "cluster_nodes_names" {
  value = "${module.netweaver_node.configuration["hostname"]}"
}
