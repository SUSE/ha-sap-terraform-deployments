# Outputs:
# - Private IP
# - Public IP
# - Private node name
# - Public node name

# iSCSI server

output "iscsisrv_ip" {
  value = module.iscsi_server.iscsisrv_ip
}

output "iscsisrv_public_ip" {
  value = module.iscsi_server.iscsisrv_public_ip
}

output "iscsisrv_name" {
  value = module.iscsi_server.iscsisrv_name
}

output "iscsisrv_public_name" {
  value = []
}

# Cluster nodes

output "cluster_nodes_ip" {
  value = module.hana_node.cluster_nodes_ip
}

output "cluster_nodes_public_ip" {
  value = module.hana_node.cluster_nodes_public_ip
}

output "cluster_nodes_name" {
  value = module.hana_node.cluster_nodes_name
}

output "cluster_nodes_public_name" {
  value = []
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

# drbd

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

# netweaver

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

# For openQA (QA mode)

output openqa_vms {
  value = concat(module.hana_node.cluster_nodes_name, module.drbd_node.drbd_name, module.netweaver_node.netweaver_name)
}

output openqa_ips {
  value = concat(module.hana_node.cluster_nodes_public_ip, module.drbd_node.drbd_public_ip, module.netweaver_node.netweaver_public_ip)
}
