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
name_prefix: vm${var.name}
hostname: vm${var.name}0${count.index + 1}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
network_domain: "tf.local"
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
hana_scale_out_enabled: ${var.hana_scale_out_enabled}
hana_scale_out_site_01: [${join(", ", formatlist("'%s'", var.hana_scale_out_site_01))}]
hana_scale_out_site_02: [${join(", ", formatlist("'%s'", var.hana_scale_out_site_02))}]
hana_scale_out_addhosts: {${join(", ", formatlist("'%s': '%s'", keys(var.hana_scale_out_addhosts), values(var.hana_scale_out_addhosts), ), )}}
hana_scale_out_shared_storage_type: ${var.hana_scale_out_shared_storage_type}
drbd_cluster_vip: ${var.drbd_cluster_vip}
hana_data_disks_configuration: {${join(", ", formatlist("'%s': '%s'", keys(var.hana_data_disks_configuration), values(var.hana_data_disks_configuration), ), )}}
drbd_data_disks_configuration_hana: {${join(", ", formatlist("'%s': '%s'", keys(var.drbd_data_disks_configuration_hana), values(var.drbd_data_disks_configuration_hana), ), )}}
EOF
    destination = "/tmp/grains"
  }
}

module "hana_provision" {
  source               = "../../../generic_modules/salt_provisioner"
  node_count           = var.common_variables["provisioner"] == "salt" ? var.hana_count : 0
  instance_ids         = null_resource.hana_node_provisioner.*.id
  user                 = var.common_variables["authorized_user"]
  private_key          = var.common_variables["private_key"]
  bastion_host         = var.bastion_host
  bastion_private_key  = var.common_variables["bastion_private_key"]
  public_ips           = local.provisioning_addresses
  background           = var.common_variables["background"]
}
