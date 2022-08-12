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

output "hana_vip" {
  value = var.hana_active_active == true ? [module.common_variables.configuration["hana"]["cluster_vip"], module.common_variables.configuration["hana"]["cluster_vip_secondary"]] : [module.common_variables.configuration["hana"]["cluster_vip"]]
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

output "drbd_vip" {
  value = var.drbd_enabled == true ? [module.common_variables.configuration["drbd"]["cluster_vip"]] : []
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

output "netweaver_vip" {
  value = var.netweaver_enabled == true ? local.netweaver_virtual_ips : []
}

# ssh variables

output "ssh_user" {
  value = var.admin_user
}

# no ssh key used to connect
#output "ssh_private_key" {
#  value = var.private_key
#}
#
#output "ssh_public_key" {
#  value = var.public_key
#}

# no bastion implemented
#output "ssh_bastion_private_key" {
#  value = var.bastion_private_key == "" ? var.private_key : var.bastion_private_key
#}
#
#output "ssh_bastion_public_key" {
#  value = var.bastion_public_key == "" ? var.public_key : var.bastion_public_key
#}
