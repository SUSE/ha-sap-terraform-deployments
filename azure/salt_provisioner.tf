# This file contains the salt provisioning logic.
# It will be executed if 'provisioner' is set to salt (default option) and the
# iscsi and hana node resources are created (check triggers option).

# Template file to launch the salt provisioing script
data "template_file" "salt_provisioner" {
  template = file("../salt/salt_provisioner_script.tpl")

  vars = {
    regcode = var.reg_code
  }
}

resource "null_resource" "iscsi_provisioner" {
  count = var.provisioner == "salt" ? 1 : 0

  triggers = {
    iscsi_id = join(",", azurerm_virtual_machine.iscsisrv.*.id)
  }

  connection {
    host        = data.azurerm_public_ip.iscsisrv.ip_address
    type        = "ssh"
    user        = var.admin_user
    private_key = file(var.private_key_location)
  }

  provisioner "file" {
    source      = "../salt"
    destination = "/tmp"
  }

  provisioner "file" {
    content     = data.template_file.salt_provisioner.rendered
    destination = "/tmp/salt_provisioner.sh"
  }

  provisioner "file" {
    content = <<EOF
provider: azure
role: iscsi_srv
iscsi_srv_ip: ${azurerm_network_interface.iscsisrv.private_ip_address}
iscsidev: ${var.iscsidev}
qa_mode: ${var.qa_mode}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules), ), )}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}

partitions:
  1:
    start: 1
    end: 20%
  2:
    start: 20%
    end: 40%
  3:
    start: 40%
    end: 60%
  4:
    start: 60%
    end: 80%
  5:
    start: 80%
    end: 100%

EOF


    destination = "/tmp/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "${var.background ? "nohup" : ""} sudo sh /tmp/salt_provisioner.sh > /tmp/provisioning.log ${var.background ? "&" : ""}",
      "return_code=$? && sleep 1 && exit $return_code",
    ] # Workaround to let the process start in background properly
  }
}

resource "null_resource" "monitoring_provisioner" {
  count = var.provisioner == "salt" && var.monitoring_enabled ? 1 : 0

  triggers = {
    monitoring_id = azurerm_virtual_machine.monitoring.0.id
  }

  connection {
    host        = data.azurerm_public_ip.monitoring.0.ip_address
    type        = "ssh"
    user        = var.admin_user
    private_key = file(var.private_key_location)
  }

  provisioner "file" {
    source      = "../salt"
    destination = "/tmp"
  }

  provisioner "file" {
    content     = data.template_file.salt_provisioner.rendered
    destination = "/tmp/salt_provisioner.sh"
  }

  provisioner "file" {
    content = <<EOF
provider: azure
role: monitoring
name_prefix: vmmonitoring
hostname: "vmmonitoring"
timezone: ${var.timezone}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules), ), )}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
authorized_keys: [${trimspace(file(var.public_key_location))},${trimspace(file(var.public_key_location))}]
host_ips: [${join(", ", formatlist("'%s'", [var.monitoring_srv_ip]))}]
host_ip: ${var.monitoring_srv_ip}
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
monitored_hosts: [${join(", ", formatlist("'%s'", var.host_ips))}]
drbd_monitored_hosts: [${join(", ", formatlist("'%s'", var.drbd_enabled ? var.drbd_ips : []))}]
nw_monitored_hosts: [${join(", ", formatlist("'%s'", var.netweaver_enabled ? var.netweaver_ips : []))}]
network_domain: "tf.local"
EOF

    destination = "/tmp/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "${var.background ? "nohup" : ""} sudo sh /tmp/salt_provisioner.sh > /tmp/provisioning.log ${var.background ? "&" : ""}",
      "return_code=$? && sleep 1 && exit $return_code",
    ] # Workaround to let the process start in background properly
  }

}
