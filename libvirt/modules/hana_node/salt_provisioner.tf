# This file contains the salt provisioning logic.
# It will be executed if 'provisioner' is set to 'salt' (default option) and the
# libvirt_domain.domain (hana_node) resources are created (check triggers option).

# Template file to launch the salt provisioning script
data "template_file" "hana_salt_provisioner" {
  template = file("../salt/salt_provisioner_script.tpl")

  vars = {
    regcode = var.reg_code
  }
}

resource "null_resource" "hana_node_provisioner" {
  count = var.provisioner == "salt" ? var.hana_count : 0
  triggers = {
    hana_ids = libvirt_domain.hana_domain[count.index].id
  }

  connection {
    host     = libvirt_domain.hana_domain[count.index].network_interface.0.addresses.0
    user     = "root"
    password = "linux"
  }

  provisioner "file" {
    source      = "../salt"
    destination = "/tmp"
  }

  provisioner "file" {
    content     = data.template_file.hana_salt_provisioner.rendered
    destination = "/tmp/salt_provisioner.sh"
  }

  provisioner "file" {
    content = <<EOF
name_prefix: ${terraform.workspace}-${var.name}
hostname: ${terraform.workspace}-${var.name}${var.hana_count > 1 ? "0${count.index + 1}" : ""}
network_domain: ${var.network_domain}
timezone: ${var.timezone}
reg_code: ${var.reg_code}
devel_mode: ${var.devel_mode}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ",formatlist("'%s': '%s'",keys(var.reg_additional_modules),values(var.reg_additional_modules),),)}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
authorized_keys: [${trimspace(file(var.public_key_location))}]
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
host_ip: ${element(var.host_ips, count.index)}
provider: libvirt
role: hana_node
scenario_type: ${var.scenario_type}
hana_disk_device: /dev/vdb
shared_storage_type: ${var.shared_storage_type}
sbd_disk_device: "${var.shared_storage_type == "iscsi" ? "/dev/sda" : "/dev/vdc"}"
iscsi_srv_ip: ${var.iscsi_srv_ip}
qa_mode: ${var.qa_mode}
hwcct: ${var.hwcct}
hana_fstype: ${var.hana_fstype}
hana_inst_folder: ${var.hana_inst_folder}
hana_inst_media: ${var.hana_inst_media}
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
monitoring_enabled: ${var.monitoring_enabled}
EOF
  destination = "/tmp/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "${var.background ? "nohup" : ""} sh /tmp/salt_provisioner.sh > /tmp/provisioning.log ${var.background ? "&" : ""}",
      "return_code=$? && sleep 1 && exit $return_code",
    ] # Workaround to let the process start in background properly
  }
}

module "hana_on_destroy" {
  source       = "../../../generic_modules/on_destroy"
  node_count   = var.provisioner == "salt" ? var.hana_count : 0
  instance_ids = libvirt_domain.hana_domain.*.id
  user         = "root"
  password     = "linux"
  public_ips   = libvirt_domain.hana_domain.*.network_interface.0.addresses.0
  dependencies = [libvirt_domain.hana_domain]
}
