resource "null_resource" "hana_node_provisioner" {
  count = var.common_variables["provisioner"] == "salt" ? var.hana_count : 0

  triggers = {
    cluster_instance_ids = join(",", azurerm_virtual_machine.hana.*.id)
  }

  connection {
    host        = element(local.provisioning_addresses, count.index)
    type        = "ssh"
    user        = var.common_variables["authorized_user"]
    private_key = var.common_variables["private_key"]

    bastion_host        = var.bastion_host
    bastion_user        = var.common_variables["authorized_user"]
    bastion_private_key = var.common_variables["bastion_private_key"]
  }

  provisioner "file" {
    content     = <<EOF
role: hana_node
${var.common_variables["grains_output"]}
${var.common_variables["hana_grains_output"]}
name_prefix: ${local.hostname}
hostname: ${local.hostname}${format("%02d", count.index + 1)}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
network_domain: ${var.network_domain}
hana_data_disks_configuration: {${join(", ", formatlist("'%s': '%s'", keys(var.hana_data_disks_configuration), values(var.hana_data_disks_configuration), ), )}}
storage_account_name: ${var.storage_account_name}
storage_account_key: ${var.storage_account_key}
sbd_lun_index: 0
iscsi_srv_ip: ${var.iscsi_srv_ip}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
subscription_id: ${var.subscription_id}
tenant_id: ${var.tenant_id}
resource_group_name: ${var.resource_group_name}
fence_agent_app_id: ${var.fence_agent_app_id}
fence_agent_client_secret: ${var.fence_agent_client_secret}
anf_mount_ip:
  data: [ ${local.shared_storage_anf == 1 ? join(", ", azurerm_netapp_volume.hana-netapp-volume-data.*.mount_ip_addresses.0) : ""} ]
  log: [ ${local.shared_storage_anf == 1 ? join(", ", azurerm_netapp_volume.hana-netapp-volume-log.*.mount_ip_addresses.0) : ""} ]
  backup: [ ${local.shared_storage_anf == 1 ? join(", ", azurerm_netapp_volume.hana-netapp-volume-backup.*.mount_ip_addresses.0) : ""} ]
  shared: [ ${local.shared_storage_anf == 1 ? join(", ", azurerm_netapp_volume.hana-netapp-volume-shared.*.mount_ip_addresses.0) : ""} ]
EOF
    destination = "/tmp/grains"
  }
}

module "hana_provision" {
  source              = "../../../generic_modules/salt_provisioner"
  node_count          = var.common_variables["provisioner"] == "salt" ? var.hana_count : 0
  instance_ids        = null_resource.hana_node_provisioner.*.id
  user                = var.common_variables["authorized_user"]
  private_key         = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips          = local.provisioning_addresses
  background          = var.common_variables["background"]
}
