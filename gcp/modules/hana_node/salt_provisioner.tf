resource "null_resource" "hana_node_provisioner" {
  count = var.provisioner == "salt" ? var.hana_count : 0

  triggers = {
    cluster_instance_ids = join(",", google_compute_instance.clusternodes.*.id)
  }

  connection {
    host = element(
      google_compute_instance.clusternodes.*.network_interface.0.access_config.0.nat_ip,
      count.index,
    )
    type        = "ssh"
    user        = "root"
    private_key = file(var.private_key_location)
  }

  provisioner "file" {
    source      = var.gcp_credentials_file
    destination = "/root/google_credentials.json"
  }

  provisioner "file" {
    content = <<EOF
provider: gcp
role: hana_node
devel_mode: ${var.devel_mode}
scenario_type: ${var.scenario_type}
name_prefix: ${terraform.workspace}-hana
hostname: ${terraform.workspace}-hana0${count.index + 1}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
network_domain: "tf.local"
shared_storage_type: iscsi
sbd_disk_index: 1
hana_inst_folder: ${var.hana_inst_folder}
hana_platform_folder: ${var.hana_platform_folder}
hana_sapcar_exe: ${var.hana_sapcar_exe}
hdbserver_sar: ${var.hdbserver_sar}
hana_extract_dir: ${var.hana_extract_dir}
hana_disk_device: ${format("%s%s","/dev/disk/by-id/google-", element(google_compute_instance.clusternodes.*.attached_disk.0.device_name, count.index))}
hana_backup_device: ${format("%s%s","/dev/disk/by-id/google-", element(google_compute_instance.clusternodes.*.attached_disk.1.device_name, count.index))}
hana_inst_disk_device: ${format("%s%s","/dev/disk/by-id/google-", element(google_compute_instance.clusternodes.*.attached_disk.2.device_name, count.index))}
hana_fstype: ${var.hana_fstype}
hana_cluster_vip: ${var.hana_cluster_vip}
gcp_credentials_file: ${var.gcp_credentials_file}
vpc_network_name: ${var.network_name}
route_table: ${google_compute_route.hana-route[0].name}
sap_hana_deployment_bucket: ${var.sap_hana_deployment_bucket}
iscsi_srv_ip: ${var.iscsi_srv_ip}
init_type: ${var.init_type}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
qa_mode: ${var.qa_mode}
hwcct: ${var.hwcct}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
monitoring_enabled: ${var.monitoring_enabled}
reg_additional_modules: {${join(
    ", ",
    formatlist(
      "'%s': '%s'",
      keys(var.reg_additional_modules),
      values(var.reg_additional_modules),
    ),
)}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
EOF
destination = "/tmp/grains"
}
}

module "hana_provision" {
  source               = "../../../generic_modules/salt_provisioner"
  node_count           = var.provisioner == "salt" ? var.hana_count : 0
  instance_ids         = null_resource.hana_node_provisioner.*.id
  user                 = "root"
  private_key_location = var.private_key_location
  public_ips           = google_compute_instance.clusternodes.*.network_interface.0.access_config.0.nat_ip
  background           = var.background
}
