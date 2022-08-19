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
