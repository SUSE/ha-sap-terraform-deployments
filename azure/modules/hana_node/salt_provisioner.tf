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
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
hostname: vm${var.name}${var.hana_count > 1 ? "0${count.index + 1}" : ""}
network_domain: "tf.local"
shared_storage_type: iscsi
sbd_disk_device: /dev/sdf
hana_inst_master: ${var.hana_inst_master}
hana_inst_folder: ${var.hana_inst_folder}
hana_platform_folder: ${var.hana_platform_folder}
hana_sapcar_exe: ${var.hana_sapcar_exe}
hdbserver_sar: ${var.hdbserver_sar}
hana_extract_dir: ${var.hana_extract_dir}
hana_disk_device: ${var.hana_disk_device}
hana_fstype: ${var.hana_fstype}
storage_account_name: ${var.storage_account_name}
storage_account_key: ${var.storage_account_key}
iscsi_srv_ip: ${var.iscsi_srv_ip}
hana_cluster_vip: ${azurerm_lb.hana-load-balancer.private_ip_address}
init_type: ${var.init_type}
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
