locals {
  gcp_credentials_dest = "/root/google_credentials.json"
}

resource "null_resource" "netweaver_provisioner" {
  count = var.common_variables["provisioner"] == "salt" ? local.vm_count : 0

  triggers = {
    netweaver_id = join(",", google_compute_instance.netweaver.*.id)
  }

  connection {
    host = element(
      google_compute_instance.netweaver.*.network_interface.0.access_config.0.nat_ip,
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
    content     = <<EOF
role: netweaver_node
${var.common_variables["grains_output"]}
name_prefix: ${var.common_variables["deployment_name"]}-netweaver
hostname: ${var.common_variables["deployment_name"]}-netweaver0${count.index + 1}
network_domain: ${var.network_domain}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
virtual_host_ips: [${join(", ", formatlist("'%s'", var.virtual_host_ips))}]
host_ip: ${element(var.host_ips, count.index)}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
gcp_credentials_file: ${local.gcp_credentials_dest}
ha_enabled: ${var.ha_enabled}
fencing_mechanism: ${var.fencing_mechanism}
sbd_storage_type: ${var.sbd_storage_type}
sbd_lun_index: 1
iscsi_srv_ip: ${var.iscsi_srv_ip}
netweaver_software_bucket: ${var.netweaver_software_bucket}
netweaver_sid: ${var.netweaver_sid}
ascs_instance_number: ${var.ascs_instance_number}
ers_instance_number: ${var.ers_instance_number}
pas_instance_number: ${var.pas_instance_number}
netweaver_master_password: ${var.netweaver_master_password}
netweaver_product_id: ${var.netweaver_product_id}
netweaver_inst_folder: ${var.netweaver_inst_folder}
netweaver_extract_dir: ${var.netweaver_extract_dir}
netweaver_swpm_folder: ${var.netweaver_swpm_folder}
netweaver_sapcar_exe: ${var.netweaver_sapcar_exe}
netweaver_swpm_sar: ${var.netweaver_swpm_sar}
netweaver_sapexe_folder: ${var.netweaver_sapexe_folder}
netweaver_additional_dvds: [${join(", ", formatlist("'%s'", var.netweaver_additional_dvds))}]
netweaver_nfs_share: ${var.netweaver_nfs_share}
netweaver_inst_disk_device: ${format("%s%s","/dev/disk/by-id/google-", element(google_compute_instance.netweaver.*.attached_disk.0.device_name, count.index))}
hana_ip: ${var.hana_ip}
hana_sid: ${var.hana_sid}
hana_instance_number: ${var.hana_instance_number}
hana_master_password: ${var.hana_master_password}
vpc_network_name: ${var.network_name}
ascs_route_name: ${google_compute_route.nw-ascs-route[0].name}
ers_route_name: ${google_compute_route.nw-ers-route[0].name}

EOF
    destination = "/tmp/grains"
  }
}

module "netweaver_provision" {
  source               = "../../../generic_modules/salt_provisioner"
  node_count           = var.common_variables["provisioner"] == "salt" ? local.vm_count : 0
  instance_ids         = null_resource.netweaver_provisioner.*.id
  user                 = "root"
  private_key          = var.common_variables["private_key"]
  public_ips           = google_compute_instance.netweaver.*.network_interface.0.access_config.0.nat_ip
  background           = var.common_variables["background"]
}
