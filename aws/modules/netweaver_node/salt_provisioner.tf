resource "null_resource" "netweaver_provisioner" {
  count = var.common_variables["provisioner"] == "salt" ? local.vm_count : 0

  triggers = {
    netweaver_id = join(",", aws_instance.netweaver.*.id)
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
    source      = var.aws_access_key_id == "" || var.aws_secret_access_key == "" ? var.aws_credentials : "/dev/null"
    destination = "/tmp/credentials"
  }

  provisioner "file" {
    content     = <<EOF
role: netweaver_node
${var.common_variables["grains_output"]}
${var.common_variables["netweaver_grains_output"]}
region: ${var.aws_region}
name_prefix: ${local.hostname}
hostname: ${local.hostname}${format("%02d", count.index + 1)}
network_domain: ${var.network_domain}
aws_cluster_profile: Cluster
aws_instance_tag: ${var.common_variables["deployment_name"]}-cluster
aws_credentials_file: /tmp/credentials
aws_access_key_id: ${var.aws_access_key_id}
aws_secret_access_key: ${var.aws_secret_access_key}
route_table: ${var.route_table_id}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
virtual_host_ips: [${join(", ", formatlist("'%s'", var.virtual_host_ips))}]
host_ip: ${element(var.host_ips, count.index)}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
sbd_lun_index: 1
iscsi_srv_ip: ${var.iscsi_srv_ip}
app_server_count: ${var.app_server_count}
netweaver_inst_disk_device: /dev/nvme1n1
s3_bucket: ${var.s3_bucket}
efs_mount_ip:
  sapmnt: [ ${local.shared_storage_efs == 1 ? join("", aws_efs_file_system.netweaver-efs.*.dns_name) : ""} ]
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
  public_ips          = local.provisioning_addresses
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  background          = var.common_variables["background"]
}
