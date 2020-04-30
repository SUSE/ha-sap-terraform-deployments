resource "null_resource" "monitoring_provisioner" {
  count = var.provisioner == "salt" && var.monitoring_enabled ? 1 : 0

  triggers = {
    monitoring_id = aws_instance.monitoring.0.id
  }

  connection {
    host        = aws_instance.monitoring.0.public_ip
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.private_key_location)
  }

  provisioner "file" {
    content = <<EOF
provider: aws
region: ${var.aws_region}
role: monitoring
name_prefix: monitoring
hostname: monitoring
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
timezone: ${var.timezone}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules)))}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
host_ip: ${var.monitoring_srv_ip}
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
monitored_hosts: [${join(", ", formatlist("'%s'", var.host_ips))}]
nw_monitored_hosts: [${join(", ", formatlist("'%s'", var.netweaver_enabled ? var.netweaver_ips : []))}]
network_domain: "tf.local"
EOF

    destination = "/tmp/grains"
  }
}

module "monitoring_provision" {
  source               = "../../../generic_modules/salt_provisioner"
  node_count           = var.provisioner == "salt" && var.monitoring_enabled ? 1 : 0
  instance_ids         = null_resource.monitoring_provisioner.*.id
  user                 = "ec2-user"
  private_key_location = var.private_key_location
  public_ips           = aws_instance.monitoring.*.public_ip
  background           = var.background
}
