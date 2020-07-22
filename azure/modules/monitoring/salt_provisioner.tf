resource "null_resource" "monitoring_provisioner" {
  count = var.provisioner == "salt" && var.monitoring_enabled ? 1 : 0

  triggers = {
    monitoring_id = azurerm_virtual_machine.monitoring.0.id
  }

  connection {
    host        = element(local.provisioning_addresses, count.index)
    type        = "ssh"
    user        = var.admin_user
    private_key = file(var.private_key_location)

    bastion_host        = var.bastion_host
    bastion_user        = var.admin_user
    bastion_private_key = file(var.bastion_private_key)
  }

  provisioner "file" {
    content     = <<EOF
provider: azure
role: monitoring_srv
name_prefix: vmmonitoring
hostname: vmmonitoring
timezone: ${var.timezone}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules), ), )}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
authorized_keys: [${trimspace(file(var.public_key_location))},${trimspace(file(var.public_key_location))}]
host_ip: ${var.monitoring_srv_ip}
public_ip: ${var.bastion_enabled ? data.azurerm_network_interface.monitoring.0.private_ip_address : data.azurerm_public_ip.monitoring.0.ip_address}
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
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
  node_count           = var.provisioner == "salt" && var.monitoring_enabled ? 1 : 0
  instance_ids         = null_resource.monitoring_provisioner.*.id
  user                 = var.admin_user
  private_key_location = var.private_key_location
  bastion_host         = var.bastion_host
  bastion_private_key  = var.bastion_private_key
  public_ips           = local.provisioning_addresses
  background           = var.background
}
