data "aws_instance" "bastion" {
  count       = var.bastion_count
  instance_id = element(aws_instance.bastion.*.id, count.index)
}

output "bastion_ip" {
  value = join("", data.aws_instance.bastion.*.private_ip)
}

output "bastion_public_ip" {
  value = join("", data.aws_instance.bastion.*.public_ip)
}

output "bastion_name" {
  value = join("", data.aws_instance.bastion.*.tags.Name)
}

output "bastion_id" {
  value = join("", data.aws_instance.bastion.*.id)
}

output "bastion_public_name" {
  value = join("", data.aws_instance.bastion.*.public_dns)
}

