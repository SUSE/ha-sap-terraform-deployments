# Outputs:
# - Private IP
# - Public IP
# - Private node name
# - Public node name

# iSCSI server

data "aws_instance" "iscsisrv" {
  instance_id = aws_instance.iscsisrv.id
}

output "iscsisrv_ip" {
  value = [data.aws_instance.iscsisrv.private_ip]
}

output "iscsisrv_public_ip" {
  value = [data.aws_instance.iscsisrv.public_ip]
}

output "iscsisrv_name" {
  value = [data.aws_instance.iscsisrv.id]
}

output "iscsisrv_public_name" {
  value = [data.aws_instance.iscsisrv.public_dns]
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
  value = module.hana_node.cluster_nodes_public_name
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
