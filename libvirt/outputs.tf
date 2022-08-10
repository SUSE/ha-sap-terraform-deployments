# Outputs: IP address and port where the service will be listening on

output "hana_ip" {
  value = module.hana_node.output_data.private_addresses
}

output "hana_public_ip" {
  value = module.hana_node.output_data.addresses
}

output "hana_name" {
  value = module.hana_node.output_data.name
}

output "hana_public_name" {
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

output "iscsi_ip" {
  value = module.iscsi_server.output_data.private_addresses
}

output "iscsi_public_ip" {
  value = module.iscsi_server.output_data.addresses
}

output "iscsi_name" {
  value = module.iscsi_server.output_data.name
}

output "iscsi_public_name" {
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

output "netweaver_ip" {
  value = module.netweaver_node.output_data.private_addresses
}

output "netweaver_public_ip" {
  value = module.netweaver_node.output_data.addresses
}

output "netweaver_name" {
  value = module.netweaver_node.output_data.name
}

output "netweaver_public_name" {
  value = []
}
