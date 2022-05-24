resource "null_resource" "wait_after_cloud_init" {
  count = var.common_variables["provisioner"] == "salt" && var.monitoring_enabled ? 1 : 0

  triggers = {
    monitoring_id = libvirt_domain.monitoring_domain.0.id
  }

  provisioner "remote-exec" {
    inline = [
      "if which cloud-init; then cloud-init status --wait; else echo no cloud-init installed; fi"
    ]
  }

  depends_on = [libvirt_domain.monitoring_domain.0]
  connection {
    host     = libvirt_domain.monitoring_domain.0.network_interface.0.addresses.0
    user     = "root"
    password = "linux"
  }
}

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
${var.common_variables["monitoring_grains_output"]}
name_prefix: ${local.hostname}
hostname: ${local.hostname}
timezone: ${var.timezone}
network_domain: ${var.network_domain}
host_ip: ${var.monitoring_srv_ip}
public_ip: ${libvirt_domain.monitoring_domain[0].network_interface[0].addresses[0]}
EOF
    destination = "/tmp/grains"
  }

  depends_on = [null_resource.wait_after_cloud_init]
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
