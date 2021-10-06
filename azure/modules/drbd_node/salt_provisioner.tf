resource "null_resource" "drbd_provisioner" {
  count = var.common_variables["provisioner"] == "salt" ? var.drbd_count : 0

  triggers = {
    iscsi_id = join(",", azurerm_virtual_machine.drbd.*.id)
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
role: drbd_node
${var.common_variables["grains_output"]}
name_prefix: ${local.hostname}
hostname: ${local.hostname}${format("%02d", count.index + 1)}
network_domain: ${var.network_domain}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
host_ip: ${element(var.host_ips, count.index)}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
drbd_disk_device: /dev/disk/azure/scsi1/lun0
drbd_cluster_vip: ${var.drbd_cluster_vip}
fencing_mechanism: ${var.fencing_mechanism}
sbd_storage_type: ${var.sbd_storage_type}
sbd_lun_index: 2
iscsi_srv_ip: ${var.iscsi_srv_ip}
nfs_mounting_point: ${var.nfs_mounting_point}
nfs_export_name: ${var.nfs_export_name}
partitions:
  1:
    start: 0%
    end: 100%
subscription_id: ${var.subscription_id}
tenant_id: ${var.tenant_id}
resource_group_name: ${var.resource_group_name}
fence_agent_app_id: ${var.fence_agent_app_id}
fence_agent_client_secret: ${var.fence_agent_client_secret}
  EOF
    destination = "/tmp/grains"
  }
}

module "drbd_provision" {
  source              = "../../../generic_modules/salt_provisioner"
  node_count          = var.common_variables["provisioner"] == "salt" ? var.drbd_count : 0
  instance_ids        = null_resource.drbd_provisioner.*.id
  user                = var.common_variables["authorized_user"]
  private_key         = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips          = local.provisioning_addresses
  background          = var.common_variables["background"]
}
