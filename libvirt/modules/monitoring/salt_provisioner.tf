resource "null_resource" "monitoring_provisioner" {
  count = var.common_variables["provisioner"] == "salt" && var.monitoring_enabled ? 1 : 0
  triggers = {
    monitoring_id = libvirt_domain.monitoring_domain.0.id
  }

  connection {
    host     = libvirt_domain.monitoring_domain.0.network_interface.0.addresses.0
    user     = "root"
    password = "linux"
  }

  provisioner "file" {
    content     = <<EOF
role: monitoring_srv
${var.common_variables["grains_output"]}
name_prefix: ${var.common_variables["deployment_name"]}-${var.name}
hostname: ${var.common_variables["deployment_name"]}-${var.name}
timezone: ${var.timezone}
network_domain: ${var.network_domain}
host_ip: ${var.monitoring_srv_ip}
public_ip: ${libvirt_domain.monitoring_domain[0].network_interface[0].addresses[0]}
hana_targets: [${join(", ", formatlist("'%s'", var.hana_targets))}]
drbd_targets: [${join(", ", formatlist("'%s'", var.drbd_targets))}]
netweaver_targets: [${join(", ", formatlist("'%s'", var.netweaver_targets))}]
EOF
    destination = "/tmp/grains"
  }
}

module "monitoring_provision" {
  source       = "../../../generic_modules/salt_provisioner"
  node_count   = var.common_variables["provisioner"] == "salt" && var.monitoring_enabled ? 1 : 0
  instance_ids = null_resource.monitoring_provisioner.*.id
  user         = "root"
  password     = "linux"
  public_ips   = libvirt_domain.monitoring_domain.*.network_interface.0.addresses.0
  background   = var.common_variables["background"]
}
