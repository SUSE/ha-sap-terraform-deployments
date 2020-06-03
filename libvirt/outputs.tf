# Outputs: IP address and port where the service will be listening on

output "cluster_nodes_ip" {
  value = module.hana_node.output_data.private_addresses
}

output "cluster_nodes_public_ip" {
  value = module.hana_node.output_data.addresses
}

output "cluster_nodes_name" {
  value = module.hana_node.output_data.name
}

output "cluster_nodes_public_name" {
  value = []
}

output "drbd_ip" {
  value = module.drbd_node.output_data.private_addresses
}

output "drbd_public_ip" {
  value = module.drbd_node.output_data.addresses
}

output "drbd_name" {
  value = module.drbd_node.output_data.name
}

output "drbd_public_name" {
  value = []
}

output "iscsisrv_ip" {
  value = module.iscsi_server.output_data.private_addresses
}

output "iscsisrv_public_ip" {
  value = module.iscsi_server.output_data.addresses
}

output "iscsisrv_name" {
  value = module.iscsi_server.output_data.name
}

output "iscsisrv_public_name" {
  value = []
}

output "monitoring_ip" {
  value = module.monitoring.output_data.private_address
}

output "monitoring_public_ip" {
  value = module.monitoring.output_data.address
}

output "monitoring_name" {
  value = module.monitoring.output_data.name
}

output "monitoring_public_name" {
  value = ""
}

output "netweaver_nodes_ip" {
  value = module.netweaver_node.output_data.private_addresses
}

output "netweaver_nodes_public_ip" {
  value = module.netweaver_node.output_data.addresses
}

output "netweaver_nodes_name" {
  value = module.netweaver_node.output_data.name
}

output "netweaver_nodes_public_name" {
  value = []
}
