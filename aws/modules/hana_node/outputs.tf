data "aws_instance" "clusternodes" {
  count       = var.hana_count
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
