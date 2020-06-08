resource "null_resource" "netweaver_provisioner" {
  count = var.provisioner == "salt" ? local.vm_count : 0

  triggers = {
    netweaver_id = join(",", azurerm_virtual_machine.netweaver.*.id)
  }

  connection {
    host        = element(local.provisioning_addresses, count.index)
    type        = "ssh"
    user        = var.admin_user
    private_key = file(var.private_key_location)

    bastion_host        = var.bastion_host
    bastion_user        = var.admin_user
    bastion_private_key = file(var.private_key_location)
  }

  provisioner "file" {
    content     = <<EOF
provider: azure
role: netweaver_node
name_prefix: vmnetweaver
hostname: vmnetweaver0${count.index + 1}
network_domain: ${var.network_domain}
additional_packages: []
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules), ), )}}
authorized_keys: [${trimspace(file(var.public_key_location))}]
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
virtual_host_ips: [${join(", ", formatlist("'%s'", var.virtual_host_ips))}]
host_ip: ${element(var.host_ips, count.index)}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
ha_enabled: ${var.ha_enabled}
app_server_count: ${var.app_server_count}
additional_lun: ${count.index < var.xscs_server_count ? "" : local.additional_lun_number}
sbd_enabled: ${var.sbd_enabled}
sbd_storage_type: ${var.sbd_storage_type}
sbd_disk_index: 2
iscsi_srv_ip: ${var.iscsi_srv_ip}
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
monitoring_enabled: ${var.monitoring_enabled}
devel_mode: ${var.devel_mode}
qa_mode: ${var.qa_mode}
ascs_instance_number: ${var.ascs_instance_number}
ers_instance_number: ${var.ers_instance_number}
pas_instance_number: ${var.pas_instance_number}
netweaver_product_id: ${var.netweaver_product_id}
netweaver_swpm_folder: ${var.netweaver_swpm_folder}
netweaver_sapcar_exe: ${var.netweaver_sapcar_exe}
netweaver_swpm_sar: ${var.netweaver_swpm_sar}
netweaver_swpm_extract_dir: ${var.netweaver_swpm_extract_dir}
netweaver_sapexe_folder: ${var.netweaver_sapexe_folder}
netweaver_additional_dvds: [${join(", ", formatlist("'%s'", var.netweaver_additional_dvds))}]
netweaver_nfs_share: ${var.netweaver_nfs_share}
storage_account_name: ${var.storage_account_name}
storage_account_key: ${var.storage_account_key}
storage_account_path: ${var.storage_account_path}
hana_ip: ${var.hana_ip}
  EOF
    destination = "/tmp/grains"
  }
}

module "netweaver_provision" {
  source               = "../../../generic_modules/salt_provisioner"
  node_count           = var.provisioner == "salt" ? local.vm_count : 0
  instance_ids         = null_resource.netweaver_provisioner.*.id
  user                 = var.admin_user
  private_key_location = var.private_key_location
  bastion_host         = var.bastion_host
  public_ips           = local.provisioning_addresses
  background           = var.background
}
