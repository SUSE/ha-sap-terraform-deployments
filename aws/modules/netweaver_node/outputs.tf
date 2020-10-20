data "aws_instance" "netweaver" {
  count       = local.vm_count
  instance_id = element(aws_instance.netweaver.*.id, count.index)
}

output "netweaver_ip" {
  value = data.aws_instance.netweaver.*.private_ip
}

output "netweaver_public_ip" {
  value = data.aws_instance.netweaver.*.public_ip
}

output "netweaver_name" {
  value = data.aws_instance.netweaver.*.id
}

output "netweaver_public_name" {
  value = data.aws_instance.netweaver.*.public_dns
}
