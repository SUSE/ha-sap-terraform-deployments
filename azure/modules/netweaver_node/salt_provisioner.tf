resource "null_resource" "netweaver_provisioner" {
  count = var.common_variables["provisioner"] == "salt" ? local.vm_count : 0

  triggers = {
    netweaver_id = join(",", azurerm_virtual_machine.netweaver.*.id)
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
role: netweaver_node
${var.common_variables["grains_output"]}
${var.common_variables["netweaver_grains_output"]}
name_prefix: ${local.hostname}
hostname: ${local.hostname}${format("%02d", count.index + 1)}
network_domain: ${var.network_domain}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
virtual_host_ips: [${join(", ", formatlist("'%s'", var.virtual_host_ips))}]
host_ip: ${element(var.host_ips, count.index)}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
app_server_count: ${var.app_server_count}
additional_lun: ${count.index < var.xscs_server_count ? "" : local.additional_lun_number}
sbd_lun_index: 1
iscsi_srv_ip: ${var.iscsi_srv_ip}
storage_account_name: ${var.storage_account_name}
storage_account_key: ${var.storage_account_key}
storage_account_path: ${var.storage_account_path}
subscription_id: ${var.subscription_id}
tenant_id: ${var.tenant_id}
resource_group_name: ${var.resource_group_name}
fence_agent_app_id: ${var.fence_agent_app_id}
fence_agent_client_secret: ${var.fence_agent_client_secret}
anf_mount_ip:
  sapmnt: [ ${join(", ", azurerm_netapp_volume.netweaver-netapp-volume-sapmnt.*.mount_ip_addresses.0)} ]
  EOF
    destination = "/tmp/grains"
  }
}

module "netweaver_provision" {
  source              = "../../../generic_modules/salt_provisioner"
  node_count          = var.common_variables["provisioner"] == "salt" ? local.vm_count : 0
  instance_ids        = null_resource.netweaver_provisioner.*.id
  user                = var.common_variables["authorized_user"]
  private_key         = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips          = local.provisioning_addresses
  background          = var.common_variables["background"]
}
