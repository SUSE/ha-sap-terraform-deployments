# This file contains the salt provisioning logic.
# It will be executed if 'provisioner' is set to 'salt' (default option) and the
# libvirt_domain.domain (hana_node) resources are created (check triggers option).

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
    content     = <<EOF
name_prefix: ${var.name}
hostname: ${var.name}0${count.index + 1}
network_domain: ${var.network_domain}
timezone: ${var.timezone}
reg_code: ${var.reg_code}
devel_mode: ${var.devel_mode}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules), ), )}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
authorized_keys: [${trimspace(file(var.public_key_location))}]
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
host_ip: ${element(var.host_ips, count.index)}
provider: libvirt
role: hana_node
scenario_type: ${var.scenario_type}
hana_disk_device: /dev/vdb
shared_storage_type: ${var.shared_storage_type}
sbd_disk_device: "${var.shared_storage_type == "shared-disk" ? "/dev/vdc" : ""}"
sbd_disk_index: 1
iscsi_srv_ip: ${var.iscsi_srv_ip}
qa_mode: ${var.qa_mode}
hwcct: ${var.hwcct}
hana_cluster_vip: ${var.hana_cluster_vip}
hana_fstype: ${var.hana_fstype}
hana_inst_folder: ${var.hana_inst_folder}
hana_platform_folder: ${var.hana_platform_folder}
hana_sapcar_exe: ${var.hana_sapcar_exe}
hdbserver_sar: ${var.hdbserver_sar}
hana_extract_dir: ${var.hana_extract_dir}
hana_inst_media: ${var.hana_inst_media}
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
monitoring_enabled: ${var.monitoring_enabled}
EOF
    destination = "/tmp/grains"
  }
}

module "hana_provision" {
  source       = "../../../generic_modules/salt_provisioner"
  node_count   = var.provisioner == "salt" ? var.hana_count : 0
  instance_ids = null_resource.hana_node_provisioner.*.id
  user         = "root"
  password     = "linux"
  public_ips   = libvirt_domain.hana_domain.*.network_interface.0.addresses.0
  background   = var.background
}
