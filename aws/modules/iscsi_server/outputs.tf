data "aws_instance" "iscsisrv" {
  count       = var.iscsi_count
  instance_id = element(aws_instance.iscsisrv.*.id, count.index)
}

output "iscsi_ip" {
  value = data.aws_instance.iscsisrv.*.private_ip
}

output "iscsi_public_ip" {
  value = data.aws_instance.iscsisrv.*.public_ip
}

output "iscsi_name" {
  value = data.aws_instance.iscsisrv.*.id
}

output "iscsi_public_name" {
  value = data.aws_instance.iscsisrv.*.public_dns
}
