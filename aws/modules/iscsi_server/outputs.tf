data "aws_instance" "iscsisrv" {
  count       = var.iscsi_count
  instance_id = element(aws_instance.iscsisrv.*.id, count.index)
}

output "iscsisrv_ip" {
  value = data.aws_instance.iscsisrv.*.private_ip
}

output "iscsisrv_public_ip" {
  value = data.aws_instance.iscsisrv.*.public_ip
}

output "iscsisrv_name" {
  value = data.aws_instance.iscsisrv.*.id
}

output "iscsisrv_public_name" {
  value = data.aws_instance.iscsisrv.*.public_dns
}
