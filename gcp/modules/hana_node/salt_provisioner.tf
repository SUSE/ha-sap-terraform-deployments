locals {
  gcp_credentials_dest = "/root/google_credentials.json"
}

resource "null_resource" "hana_node_provisioner" {
  count = var.common_variables["provisioner"] == "salt" ? var.hana_count : 0

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
    private_key = var.common_variables["private_key"]
  }

  provisioner "file" {
    source      = var.gcp_credentials_file
    destination = local.gcp_credentials_dest
  }

  provisioner "file" {
    content = <<EOF
role: hana_node
${var.common_variables["grains_output"]}
scenario_type: ${var.scenario_type}
name_prefix: ${var.common_variables["deployment_name"]}-hana
hostname: ${var.common_variables["deployment_name"]}-hana0${count.index + 1}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
network_domain: "tf.local"
ha_enabled: ${var.ha_enabled}
fencing_mechanism: ${var.fencing_mechanism}
sbd_storage_type: ${var.sbd_storage_type}
sbd_lun_index: 0
hana_inst_folder: ${var.hana_inst_folder}
hana_platform_folder: ${var.hana_platform_folder}
hana_sapcar_exe: ${var.hana_sapcar_exe}
hana_archive_file: ${var.hana_archive_file}
hana_extract_dir: ${var.hana_extract_dir}
hana_disk_device: ${format("%s%s","/dev/disk/by-id/google-", element(google_compute_instance.clusternodes.*.attached_disk.0.device_name, count.index))}
hana_backup_device: ${format("%s%s","/dev/disk/by-id/google-", element(google_compute_instance.clusternodes.*.attached_disk.1.device_name, count.index))}
hana_inst_disk_device: ${format("%s%s","/dev/disk/by-id/google-", element(google_compute_instance.clusternodes.*.attached_disk.2.device_name, count.index))}
hana_fstype: ${var.hana_fstype}
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
gcp_credentials_file: ${local.gcp_credentials_dest}
vpc_network_name: ${var.network_name}
route_name: ${join(",", google_compute_route.hana-route.*.name)}
route_name_secondary: ${join(",", google_compute_route.hana-route-secondary.*.name)}
sap_hana_deployment_bucket: ${var.sap_hana_deployment_bucket}
iscsi_srv_ip: ${var.iscsi_srv_ip}
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
  user                 = "root"
  private_key          = var.common_variables["private_key"]
  public_ips           = google_compute_instance.clusternodes.*.network_interface.0.access_config.0.nat_ip
  background           = var.common_variables["background"]
}
