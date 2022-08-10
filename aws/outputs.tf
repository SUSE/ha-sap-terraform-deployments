# Outputs:
# - Private IP
# - Public IP
# - Private node name
# - Public node name

# Cluster nodes

output "hana_ip" {
  value = module.hana_node.hana_ip
}

output "hana_public_ip" {
  value = module.hana_node.hana_public_ip
}

output "hana_name" {
  value = module.hana_node.hana_name
}

output "hana_public_name" {
  value = module.hana_node.hana_public_name
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

output "monitoring_public_name" {
  value = module.monitoring.monitoring_public_name
}

# Netweaver

output "netweaver_ip" {
  value = module.netweaver_node.netweaver_ip
}

output "netweaver_public_ip" {
  value = module.netweaver_node.netweaver_public_ip
}

output "netweaver_name" {
  value = module.netweaver_node.netweaver_name
}

output "netweaver_public_name" {
  value = module.netweaver_node.netweaver_public_name
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

output "iscsi_public_name" {
  value = join("", module.iscsi_server.iscsi_public_name)
}

# DRBD

output "drbd_ip" {
  value = module.drbd_node.drbd_ip
}

output "drbd_public_ip" {
  value = module.drbd_node.drbd_public_ip
}

output "drbd_name" {
  value = module.drbd_node.drbd_name
}

output "drbd_public_name" {
  value = module.drbd_node.drbd_public_name
}
