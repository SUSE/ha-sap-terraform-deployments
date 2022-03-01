resource "null_resource" "majority_maker_provisioner" {
  count = var.common_variables["provisioner"] == "salt" ? var.node_count : 0

  triggers = {
    cluster_instance_ids = join(",", azurerm_virtual_machine.majority_maker.*.id)
  }

  connection {
    host        = element(local.provisioning_address, count.index)
    type        = "ssh"
    user        = var.common_variables["authorized_user"]
    private_key = var.common_variables["private_key"]

    bastion_host        = var.bastion_host
    bastion_user        = var.common_variables["authorized_user"]
    bastion_private_key = var.common_variables["bastion_private_key"]
  }

  provisioner "file" {
    content     = <<EOF
role: majority_maker_node
${var.common_variables["grains_output"]}
${var.common_variables["hana_grains_output"]}
name_prefix: vm${var.name}
hostname: vm${var.name}mm
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
node_count: ${var.hana_count + var.node_count}
majority_maker_node: vm${var.name}mm
majority_maker_ip: ${var.majority_maker_ip}
EOF
    destination = "/tmp/grains"
  }
}

module "majority_maker_provision" {
  source              = "../../../generic_modules/salt_provisioner"
  node_count          = var.common_variables["provisioner"] == "salt" ? var.node_count : 0
  instance_ids        = null_resource.majority_maker_provisioner.*.id
  user                = var.common_variables["authorized_user"]
  private_key         = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips          = local.provisioning_address
  background          = var.common_variables["background"]
}
