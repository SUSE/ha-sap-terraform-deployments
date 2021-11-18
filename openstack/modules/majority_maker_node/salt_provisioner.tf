resource "null_resource" "wait_after_cloud_init" {
  count = var.common_variables["provisioner"] == "salt" ? var.node_count : 0

  triggers = {
    mm_id = join(",", openstack_compute_instance_v2.majority_maker.*.id)
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]
  }
  depends_on = [openstack_compute_instance_v2.majority_maker]
  connection {
    host        = element(local.provisioning_address, count.index)
    type        = "ssh"
    user        = var.common_variables["authorized_user"]
    private_key = var.common_variables["private_key"]

    bastion_host        = var.bastion_host
    bastion_user        = var.common_variables["authorized_user"]
    bastion_private_key = var.common_variables["bastion_private_key"]

  }
}

resource "null_resource" "majority_maker_provisioner" {
  count = var.common_variables["provisioner"] == "salt" ? var.node_count : 0

  triggers = {
    mm_id = join(",", openstack_compute_instance_v2.majority_maker.*.id)
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
name_prefix: ${local.hostname}
hostname: ${local.hostname}mm
network_domain: ${var.network_domain}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
sbd_lun_index: 0
iscsi_srv_ip: ${var.iscsi_srv_ip}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
node_count: ${var.hana_count + var.node_count}
majority_maker_node: ${local.hostname}mm
majority_maker_ip: ${var.majority_maker_ip}
EOF
    destination = "/tmp/grains"
  }

  depends_on = [null_resource.wait_after_cloud_init]
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
