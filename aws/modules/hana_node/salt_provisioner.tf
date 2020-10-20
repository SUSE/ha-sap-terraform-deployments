resource "null_resource" "hana_node_provisioner" {
  count = var.common_variables["provisioner"] == "salt" ? var.hana_count : 0

  triggers = {
    cluster_instance_ids = join(",", aws_instance.clusternodes.*.id)
  }

  connection {
    host        = element(aws_instance.clusternodes.*.public_ip, count.index)
    type        = "ssh"
    user        = "ec2-user"
    private_key = var.common_variables["private_key"]
  }

  provisioner "file" {
    source      = var.aws_access_key_id == "" || var.aws_secret_access_key == "" ? var.aws_credentials : "/dev/null"
    destination = "/tmp/credentials"
  }

  provisioner "file" {
    content     = <<EOF
role: hana_node
${var.common_variables["grains_output"]}
region: ${var.aws_region}
aws_cluster_profile: Cluster
aws_instance_tag: ${var.common_variables["deployment_name"]}-cluster
aws_credentials_file: /tmp/credentials
aws_access_key_id: ${var.aws_access_key_id}
aws_secret_access_key: ${var.aws_secret_access_key}
hana_sid: ${var.hana_sid}
hana_instance_number: ${var.hana_instance_number}
hana_cost_optimized_sid: ${var.hana_cost_optimized_sid}
hana_cost_optimized_instance_number: ${var.hana_cost_optimized_instance_number}
hana_master_password: ${var.hana_master_password}
hana_cost_optimized_master_password: ${var.hana_cost_optimized_master_password}
hana_primary_site: ${var.hana_primary_site}
hana_secondary_site: ${var.hana_secondary_site}
hana_cluster_vip: ${var.hana_cluster_vip}
hana_cluster_vip_secondary: ${var.hana_cluster_vip_secondary}
route_table: ${var.route_table_id}
scenario_type: ${var.scenario_type}
name_prefix: ${var.name}
hostname: ${var.name}0${count.index + 1}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
network_domain: "tf.local"
ha_enabled: ${var.ha_enabled}
fencing_mechanism: ${var.fencing_mechanism}
sbd_storage_type: ${var.sbd_storage_type}
sbd_lun_index: 0
iscsi_srv_ip: ${var.iscsi_srv_ip}
hana_inst_master: ${var.hana_inst_master}
hana_inst_folder: ${var.hana_inst_folder}
hana_platform_folder: ${var.hana_platform_folder}
hana_sapcar_exe: ${var.hana_sapcar_exe}
hana_archive_file: ${var.hana_archive_file}
hana_extract_dir: ${var.hana_extract_dir}
hana_disk_device: ${local.hana_disk_device}
hana_fstype: ${var.hana_fstype}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
hwcct: ${var.hwcct}
EOF
    destination = "/tmp/grains"
  }
}

module "hana_provision" {
  source               = "../../../generic_modules/salt_provisioner"
  node_count           = var.common_variables["provisioner"] == "salt" ? var.hana_count : 0
  instance_ids         = null_resource.hana_node_provisioner.*.id
  user                 = "ec2-user"
  private_key          = var.common_variables["private_key"]
  public_ips           = aws_instance.clusternodes.*.public_ip
  background           = var.common_variables["background"]
}
