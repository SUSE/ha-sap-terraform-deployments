# Outputs: IP address and port where the service will be listening on

output "cluster_nodes_ip" {
  value = module.hana_node.addresses["addresses"]
}

output "cluster_nodes_id" {
  value = module.hana_node.configuration["id"]
}

output "cluster_nodes_names" {
  value = module.hana_node.configuration["hostname"]
}

output "iscsisrv_ip" {
  value = module.iscsi_server.addresses
}

output "iscsisrv_name" {
  value = module.iscsi_server.configuration["hostname"]
}

output "monitoring_hostname" {
  value = module.monitoring.configuration["hostname"]
}

output "monitoring_ip" {
  value = module.monitoring.addresses["addresses"]
}

