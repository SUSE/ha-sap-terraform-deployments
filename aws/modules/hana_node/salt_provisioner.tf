resource "null_resource" "hana_node_provisioner" {
  count = var.provisioner == "salt" ? var.hana_count : 0

  triggers = {
    cluster_instance_ids = join(",", aws_instance.clusternodes.*.id)
  }

  connection {
    host        = element(aws_instance.clusternodes.*.public_ip, count.index)
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.private_key_location)
  }

  provisioner "file" {
    source      = var.aws_access_key_id == "" || var.aws_secret_access_key == "" ? var.aws_credentials : "/dev/null"
    destination = "/tmp/credentials"
  }

  provisioner "file" {
    content     = <<EOF
provider: aws
region: ${var.aws_region}
role: hana_node
aws_cluster_profile: Cluster
aws_instance_tag: ${terraform.workspace}-cluster
aws_credentials_file: /tmp/credentials
aws_access_key_id: ${var.aws_access_key_id}
aws_secret_access_key: ${var.aws_secret_access_key}
hana_cluster_vip: ${var.hana_cluster_vip}
route_table: ${var.route_table_id}
scenario_type: ${var.scenario_type}
name_prefix: ${var.name}
hostname: ${var.name}0${count.index + 1}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
network_domain: "tf.local"
shared_storage_type: iscsi
sbd_disk_index: 1
hana_inst_master: ${var.hana_inst_master}
hana_inst_folder: ${var.hana_inst_folder}
hana_platform_folder: ${var.hana_platform_folder}
hana_sapcar_exe: ${var.hana_sapcar_exe}
hdbserver_sar: ${var.hdbserver_sar}
hana_extract_dir: ${var.hana_extract_dir}
hana_disk_device: ${var.hana_disk_device}
hana_fstype: ${var.hana_fstype}
iscsi_srv_ip: ${var.iscsi_srv_ip}
init_type: ${var.init_type}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules)))}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
monitoring_enabled: ${var.monitoring_enabled}
devel_mode: ${var.devel_mode}
qa_mode: ${var.qa_mode}
hwcct: ${var.hwcct}
EOF
    destination = "/tmp/grains"
  }
}

module "hana_provision" {
  source               = "../../../generic_modules/salt_provisioner"
  node_count           = var.provisioner == "salt" ? var.hana_count : 0
  instance_ids         = null_resource.hana_node_provisioner.*.id
  user                 = "ec2-user"
  private_key_location = var.private_key_location
  public_ips           = aws_instance.clusternodes.*.public_ip
  background           = var.background
}
