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

data "aws_instance" "clusternodes" {
  count       = var.ninstances
  instance_id = element(aws_instance.clusternodes.*.id, count.index)
}

output "cluster_nodes_ip" {
  value = data.aws_instance.clusternodes.*.private_ip
}

output "cluster_nodes_public_ip" {
  value = data.aws_instance.clusternodes.*.public_ip
}

output "cluster_nodes_name" {
  value = data.aws_instance.clusternodes.*.id
}

output "cluster_nodes_public_name" {
  value = data.aws_instance.clusternodes.*.public_dns
}

# Monitoring

data "aws_instance" "monitoring" {
  count       = var.monitoring_enabled == true ? 1 : 0
  instance_id = aws_instance.monitoring.0.id
}

output "monitoring_ip" {
  value = join("", data.aws_instance.monitoring.*.private_ip)
}

output "monitoring_public_ip" {
  value = join("", data.aws_instance.monitoring.*.public_ip)
}

output "monitoring_name" {
  value = join("", data.aws_instance.monitoring.*.id)
}

output "monitoring_public_name" {
  value = join("", data.aws_instance.monitoring.*.public_dns)
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
