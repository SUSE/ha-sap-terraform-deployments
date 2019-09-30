# Launch SLES-HAE of SLES4SAP cluster nodes

# Outputs: IP address and port where the service will be listening on

data "aws_instance" "iscsisrv" {
  instance_id = aws_instance.iscsisrv.id
}

output "iscsisrv_ip" {
  value = data.aws_instance.iscsisrv.public_ip
}

output "iscsisrv_name" {
  value = data.aws_instance.iscsisrv.public_dns
}


data "aws_instance" "clusternodes" {
  count       = var.ninstances
  instance_id = element(aws_instance.clusternodes.*.id, count.index)
}

output "cluster_nodes_ip" {
  value = data.aws_instance.clusternodes.*.public_ip
}

output "cluster_nodes_names" {
  value = data.aws_instance.clusternodes.*.public_dns
}


data "aws_instance" "monitoring" {
  count       = var.monitoring_enabled == true ? 1 : 0
  instance_id = element(aws_instance.monitoring.*.id, count.index)
}

output "monitoring_node_ip" {
  value = data.aws_instance.monitoring.*.public_ip
}

output "monitoring_node_name" {
  value = data.aws_instance.monitoring.*.public_dns
}