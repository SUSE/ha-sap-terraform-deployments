data "aws_instance" "majority_maker" {
  count       = var.node_count
  instance_id = element(aws_instance.majority_maker.*.id, count.index)
}

output "majority_maker_ip" {
  value = data.aws_instance.majority_maker.*.private_ip
}

output "hana_majority_maker_public_ip" {
  value = data.aws_instance.majority_maker.*.public_ip
}

output "hana_majority_maker_name" {
  value = data.aws_instance.majority_maker.*.id
}

output "hana_majority_maker_public_name" {
  value = data.aws_instance.majority_maker.*.public_dns
}
