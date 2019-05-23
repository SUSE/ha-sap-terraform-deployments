# This file contains the salt provisioning logic.
# It will be executed if 'provisioner' is set to salt (default option) and the
# iscsi and hana node resources are created (check triggers option).

terraform {
  required_version = "~> 0.11.7"
}

# Template file to launch the salt provisioing script
data "template_file" "salt_provisioner" {
  template = "${file("../../salt/salt_provisioner_script.tpl")}"

  vars {
    regcode = "${var.reg_code}"
  }
}

resource "null_resource" "iscsi_provisioner" {
  count = "${var.provisioner == "salt" ? azurerm_virtual_machine.iscsisrv.count : 0}"

  triggers = {
    iscsi_id = "${join(",", azurerm_virtual_machine.iscsisrv.*.id)}"
  }

  connection {
    host        = "${data.azurerm_public_ip.iscsisrv.ip_address}"
    type        = "ssh"
    user        = "${var.admin_user}"
    private_key = "${file("${var.private_key_location}")}"
  }

  provisioner "file" {
    source      = "../../salt"
    destination = "/tmp"
  }

  provisioner "file" {
    content     = "${data.template_file.salt_provisioner.rendered}"
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
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules)))}}
additional_repos: {${join(", ", formatlist("'%s': '%s'", keys(var.additional_repos), values(var.additional_repos)))}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}

partitions:
  1:
    start: 0
    end: 1024
  2:
    start: 1025
    end: 2048
  3:
    start: 2049
    end: 3072
  4:
    start: 3073
    end: 4096
  5:
    start: 4097
    end: 5120
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

resource "null_resource" "hana_node_provisioner" {
  count = "${var.provisioner == "salt" ? azurerm_virtual_machine.clusternodes.count : 0}"

  triggers = {
    cluster_instance_ids = "${join(",", azurerm_virtual_machine.clusternodes.*.id)}"
  }

  connection {
    host        = "${element(data.azurerm_public_ip.clusternodes.*.ip_address, count.index)}"
    type        = "ssh"
    user        = "${var.admin_user}"
    private_key = "${file("${var.private_key_location}")}"
  }

  provisioner "file" {
    source      = "../../salt"
    destination = "/tmp"
  }

  provisioner "file" {
    content     = "${data.template_file.salt_provisioner.rendered}"
    destination = "/tmp/salt_provisioner.sh"
  }

  provisioner "file" {
    content = <<EOF
provider: azure
role: hana_node
name_prefix: ${var.name}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
hostname: ${var.name}${var.ninstances > 1 ? "0${count.index  + 1}" : ""}
domain: "tf.local"
sbd_disk_device: /dev/sdd
hana_inst_master: ${var.hana_inst_master}
hana_inst_folder: ${var.hana_inst_folder}
hana_disk_device: ${var.hana_disk_device}
hana_fstype: ${var.hana_fstype}
storage_account_name: ${var.storage_account_name}
storage_account_key: ${var.storage_account_key}
iscsi_srv_ip: ${azurerm_network_interface.iscsisrv.private_ip_address}
azure_lb_ip: ${azurerm_lb.mylb.private_ip_address}
init_type: ${var.init_type}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
qa_mode: ${var.qa_mode}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules)))}}
additional_repos: {${join(", ", formatlist("'%s': '%s'", keys(var.additional_repos), values(var.additional_repos)))}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
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
