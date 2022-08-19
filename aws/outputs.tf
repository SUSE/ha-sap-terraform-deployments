# Outputs:
# - Private IP
# - Public IP
# - Private node name
# - Public node name

# Cluster nodes

output "hana_ip" {
  value = compact(module.hana_node.hana_ip)
}

output "hana_public_ip" {
  value = compact(module.hana_node.hana_public_ip)
}

output "hana_name" {
  value = compact(module.hana_node.hana_name)
}

output "hana_id" {
  value = compact(module.hana_node.hana_id)
}

output "hana_public_name" {
  value = compact(module.hana_node.hana_public_name)
}

output "hana_vip" {
  value = var.hana_active_active == true ? [module.common_variables.configuration["hana"]["cluster_vip"], module.common_variables.configuration["hana"]["cluster_vip_secondary"]] : [module.common_variables.configuration["hana"]["cluster_vip"]]
}

output "hana_majority_maker_ip" {
  value = module.hana_node.majority_maker_ip
}

output "hana_majority_maker_public_ip" {
  value = module.hana_node.hana_majority_maker_public_ip
}

output "hana_majority_maker_name" {
  value = module.hana_node.hana_majority_maker_name
}

output "hana_majority_maker_id" {
  value = module.hana_node.hana_majority_maker_id
}

output "hana_majority_maker_public_name" {
  value = module.hana_node.hana_majority_maker_public_name
}

# Monitoring

output "monitoring_ip" {
  value = module.monitoring.monitoring_ip
}

output "monitoring_public_ip" {
  value = module.monitoring.monitoring_public_ip
}

output "monitoring_name" {
  value = module.monitoring.monitoring_name
}

output "monitoring_id" {
  value = module.monitoring.monitoring_id
}

output "monitoring_public_name" {
  value = module.monitoring.monitoring_public_name
}

# Netweaver

output "netweaver_ip" {
  value = compact(module.netweaver_node.netweaver_ip)
}

output "netweaver_public_ip" {
  value = compact(module.netweaver_node.netweaver_public_ip)
}

output "netweaver_name" {
  value = compact(module.netweaver_node.netweaver_name)
}

output "netweaver_id" {
  value = compact(module.netweaver_node.netweaver_id)
}

output "netweaver_public_name" {
  value = compact(module.netweaver_node.netweaver_public_name)
}

output "netweaver_vip" {
  value = var.netweaver_enabled == true ? local.netweaver_virtual_ips : []
}

# iSCSI server

output "iscsi_ip" {
  value = join("", module.iscsi_server.iscsi_ip)
}

output "iscsi_public_ip" {
  value = join("", module.iscsi_server.iscsi_public_ip)
}

output "iscsi_name" {
  value = join("", module.iscsi_server.iscsi_name)
}

output "iscsi_id" {
  value = join("", module.iscsi_server.iscsi_id)
}

output "iscsi_public_name" {
  value = join("", module.iscsi_server.iscsi_public_name)
}

# DRBD

output "drbd_ip" {
  value = compact(module.drbd_node.drbd_ip)
}

output "drbd_public_ip" {
  value = compact(module.drbd_node.drbd_public_ip)
}

output "drbd_name" {
  value = compact(module.drbd_node.drbd_name)
}

output "drbd_id" {
  value = compact(module.drbd_node.drbd_id)
}

output "drbd_public_name" {
  value = compact(module.drbd_node.drbd_public_name)
}

output "drbd_vip" {
  value = var.drbd_enabled == true ? [module.common_variables.configuration["drbd"]["cluster_vip"]] : []
}

# no bastion on AWS yet

#output "bastion_ip" {
#  value = module.bastion.bastion_ip
#}
#
#output "bastion_public_ip" {
#  value = module.bastion.bastion_public_ip
#}
#
#output "bastion_name" {
#  value = module.bastion.bastion_name
#}
#
#output "bastion_id" {
#  value = module.bastion.bastion_id
#}
#
#output "bastion_public_name" {
#  value = module.bastion.bastion_public_name
#}

# ssh variables

output "ssh_user" {
  value = var.admin_user
}

output "ssh_private_key" {
  value = var.private_key
}

output "ssh_public_key" {
  value = var.public_key
}

# no bastion on AWS yet
#output "ssh_bastion_private_key" {
#  value = var.bastion_private_key == "" ? var.private_key : var.bastion_private_key
#}
#
#output "ssh_bastion_public_key" {
#  value = var.bastion_public_key == "" ? var.public_key : var.bastion_public_key
#}
