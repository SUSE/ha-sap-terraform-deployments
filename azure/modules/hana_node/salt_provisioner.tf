resource "null_resource" "hana_node_provisioner" {
  count = var.provisioner == "salt" ? var.hana_count : 0

  triggers = {
    cluster_instance_ids = join(",", azurerm_virtual_machine.hana.*.id)
  }

  connection {
    host = element(
      data.azurerm_public_ip.hana.*.ip_address,
      count.index,
    )
    type        = "ssh"
    user        = var.admin_user
    private_key = file(var.private_key_location)
  }

  provisioner "file" {
    content     = <<EOF
provider: azure
role: hana_node
devel_mode: ${var.devel_mode}
scenario_type: ${var.scenario_type}
name_prefix: vm${var.name}
hostname: vm${var.name}0${count.index + 1}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
network_domain: "tf.local"
hana_inst_master: ${var.hana_inst_master}
hana_inst_folder: ${var.hana_inst_folder}
hana_platform_folder: ${var.hana_platform_folder}
hana_sapcar_exe: ${var.hana_sapcar_exe}
hdbserver_sar: ${var.hdbserver_sar}
hana_extract_dir: ${var.hana_extract_dir}
hana_fstype: ${var.hana_fstype}
hana_data_disks_configuration: {${join(", ", formatlist("'%s': '%s'", keys(var.hana_data_disks_configuration), values(var.hana_data_disks_configuration), ), )}}
storage_account_name: ${var.storage_account_name}
storage_account_key: ${var.storage_account_key}
ha_enabled: ${var.ha_enabled}
sbd_enabled: ${var.sbd_enabled}
sbd_storage_type: ${var.sbd_storage_type}
sbd_disk_index: 1
iscsi_srv_ip: ${var.iscsi_srv_ip}
hana_cluster_vip: ${var.ha_enabled ? azurerm_lb.hana-load-balancer[0].private_ip_address : ""}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
qa_mode: ${var.qa_mode}
hwcct: ${var.hwcct}
reg_code: ${var.reg_code}
monitoring_enabled: ${var.monitoring_enabled}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules), ), )}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
EOF
    destination = "/tmp/grains"
  }
}

module "hana_provision" {
  source               = "../../../generic_modules/salt_provisioner"
  node_count           = var.provisioner == "salt" ? var.hana_count : 0
  instance_ids         = null_resource.hana_node_provisioner.*.id
  user                 = var.admin_user
  private_key_location = var.private_key_location
  public_ips           = data.azurerm_public_ip.hana.*.ip_address
  background           = var.background
}
