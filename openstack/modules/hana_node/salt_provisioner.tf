resource "null_resource" "wait_after_cloud_init" {
  count = var.common_variables["provisioner"] == "salt" ? var.hana_count : 0

  triggers = {
    hana_id = join(",", openstack_compute_instance_v2.hana.*.id)
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]
  }
  depends_on = [openstack_compute_instance_v2.hana]
  connection {
    host        = element(local.provisioning_addresses, count.index)
    type        = "ssh"
    user        = var.common_variables["authorized_user"]
    private_key = var.common_variables["private_key"]

    bastion_host        = var.bastion_host
    bastion_user        = var.common_variables["authorized_user"]
    bastion_private_key = var.common_variables["bastion_private_key"]

  }
}

resource "null_resource" "hana_node_provisioner" {

  count = var.common_variables["provisioner"] == "salt" ? var.hana_count : 0

  triggers = {
    hana_id = join(",", openstack_compute_instance_v2.hana.*.id)
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
network_domain: ${var.network_domain}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
sbd_lun_index: 0
hana_disk_device: /dev/sdc
hana_backup_device: /dev/sdb
iscsi_srv_ip: ${var.iscsi_srv_ip}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
nfs_mount_ip:
  data: [ ${local.shared_storage_nfs == 1 ? "${var.nfs_srv_ip}, ${var.nfs_srv_ip}" : ""} ]
  log: [ ${local.shared_storage_nfs == 1 ? "${var.nfs_srv_ip}, ${var.nfs_srv_ip}" : ""} ]
  backup: [ ${local.shared_storage_nfs == 1 ? "${var.nfs_srv_ip}, ${var.nfs_srv_ip}" : ""} ]
  shared: [ ${local.shared_storage_nfs == 1 ? "${var.nfs_srv_ip}, ${var.nfs_srv_ip}" : ""} ]
nfs_mounting_point: ${var.nfs_mounting_point}
node_count: ${var.hana_count + local.create_scale_out}
majority_maker_node: ${local.create_scale_out == 1 ? "${local.hostname}mm" : ""}
majority_maker_ip: ${local.create_scale_out == 1 ? var.majority_maker_ip : ""}
EOF
    destination = "/tmp/grains"
  }

  depends_on = [null_resource.wait_after_cloud_init]
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
