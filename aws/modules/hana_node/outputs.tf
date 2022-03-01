data "aws_instance" "hana" {
  count       = var.hana_count
  instance_id = element(aws_instance.hana.*.id, count.index)
}

output "cluster_nodes_ip" {
  value = data.aws_instance.hana.*.private_ip
}

output "cluster_nodes_public_ip" {
  value = data.aws_instance.hana.*.public_ip
}

output "cluster_nodes_name" {
  value = data.aws_instance.hana.*.id
}

output "cluster_nodes_public_name" {
  value = data.aws_instance.hana.*.public_dns
}
