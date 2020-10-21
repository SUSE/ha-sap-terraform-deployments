resource "null_resource" "monitoring_provisioner" {
  count = var.common_variables["provisioner"] == "salt" && var.monitoring_enabled ? 1 : 0

  triggers = {
    monitoring_id = aws_instance.monitoring.0.id
  }

  connection {
    host        = aws_instance.monitoring.0.public_ip
    type        = "ssh"
    user        = "ec2-user"
    private_key = var.common_variables["private_key"]
  }

  provisioner "file" {
    content = <<EOF
role: monitoring_srv
${var.common_variables["grains_output"]}
region: ${var.aws_region}
name_prefix: monitoring
hostname: monitoring
timezone: ${var.timezone}
host_ip: ${var.monitoring_srv_ip}
public_ip: ${aws_instance.monitoring[0].public_ip}
hana_targets: [${join(", ", formatlist("'%s'", var.hana_targets))}]
drbd_targets: [${join(", ", formatlist("'%s'", var.drbd_targets))}]
netweaver_targets: [${join(", ", formatlist("'%s'", var.netweaver_targets))}]
network_domain: "tf.local"
EOF

    destination = "/tmp/grains"
  }
}

module "monitoring_provision" {
  source               = "../../../generic_modules/salt_provisioner"
  node_count           = var.common_variables["provisioner"] == "salt" && var.monitoring_enabled ? 1 : 0
  instance_ids         = null_resource.monitoring_provisioner.*.id
  user                 = "ec2-user"
  private_key          = var.common_variables["private_key"]
  public_ips           = aws_instance.monitoring.*.public_ip
  background           = var.common_variables["background"]
}
