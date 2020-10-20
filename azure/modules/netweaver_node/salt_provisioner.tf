resource "null_resource" "netweaver_provisioner" {
  count = var.common_variables["provisioner"] == "salt" ? local.vm_count : 0

  triggers = {
    netweaver_id = join(",", azurerm_virtual_machine.netweaver.*.id)
  }

  connection {
    host        = element(local.provisioning_addresses, count.index)
    type        = "ssh"
    user        = var.admin_user
    private_key = var.common_variables["private_key"]

    bastion_host        = var.common_variables["bastion_host"]
    bastion_user        = var.admin_user
    bastion_private_key = var.common_variables["bastion_private_key"]
  }

  provisioner "file" {
    content     = <<EOF
role: netweaver_node
${var.common_variables["grains_output"]}
name_prefix: vmnetweaver
hostname: vmnetweaver0${count.index + 1}
network_domain: ${var.network_domain}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
virtual_host_ips: [${join(", ", formatlist("'%s'", var.virtual_host_ips))}]
host_ip: ${element(var.host_ips, count.index)}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
ha_enabled: ${var.ha_enabled}
app_server_count: ${var.app_server_count}
additional_lun: ${count.index < var.xscs_server_count ? "" : local.additional_lun_number}
fencing_mechanism: ${var.fencing_mechanism}
sbd_storage_type: ${var.sbd_storage_type}
sbd_lun_index: 1
iscsi_srv_ip: ${var.iscsi_srv_ip}
netweaver_sid: ${var.netweaver_sid}
ascs_instance_number: ${var.ascs_instance_number}
ers_instance_number: ${var.ers_instance_number}
pas_instance_number: ${var.pas_instance_number}
netweaver_master_password: ${var.netweaver_master_password}
netweaver_product_id: ${var.netweaver_product_id}
netweaver_inst_folder: ${var.netweaver_inst_folder}
netweaver_extract_dir: ${var.netweaver_extract_dir}
netweaver_swpm_folder: ${var.netweaver_swpm_folder}
netweaver_sapcar_exe: ${var.netweaver_sapcar_exe}
netweaver_swpm_sar: ${var.netweaver_swpm_sar}
netweaver_sapexe_folder: ${var.netweaver_sapexe_folder}
netweaver_additional_dvds: [${join(", ", formatlist("'%s'", var.netweaver_additional_dvds))}]
netweaver_nfs_share: ${var.netweaver_nfs_share}
storage_account_name: ${var.storage_account_name}
storage_account_key: ${var.storage_account_key}
storage_account_path: ${var.storage_account_path}
hana_ip: ${var.hana_ip}
hana_sid: ${var.hana_sid}
hana_instance_number: ${var.hana_instance_number}
hana_master_password: ${var.hana_master_password}
  EOF
    destination = "/tmp/grains"
  }
}

module "netweaver_provision" {
  source               = "../../../generic_modules/salt_provisioner"
  node_count           = var.common_variables["provisioner"] == "salt" ? local.vm_count : 0
  instance_ids         = null_resource.netweaver_provisioner.*.id
  user                 = var.admin_user
  private_key          = var.common_variables["private_key"]
  bastion_host         = var.common_variables["bastion_host"]
  bastion_private_key  = var.common_variables["bastion_private_key"]
  public_ips           = local.provisioning_addresses
  background           = var.common_variables["background"]
}
