resource "null_resource" "netweaver_provisioner" {
  count = var.provisioner == "salt" ? var.netweaver_count : 0

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
    private_key = file(var.private_key_location)
  }

  provisioner "file" {
    source      = var.gcp_credentials_file
    destination = "/root/google_credentials.json"
  }

  provisioner "file" {
    content     = <<EOF
provider: gcp
role: netweaver_node
name_prefix: ${terraform.workspace}-netweaver
hostname: ${terraform.workspace}-netweaver${var.netweaver_count > 1 ? "0${count.index + 1}" : ""}
network_domain: ${var.network_domain}
additional_packages: []
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules), ), )}}
authorized_keys: [${trimspace(file(var.public_key_location))}]
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
virtual_host_ips: [${join(", ", formatlist("'%s'", var.virtual_host_ips))}]
host_ip: ${element(var.host_ips, count.index)}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
shared_storage_type: iscsi
sbd_disk_device: /dev/sde
iscsi_srv_ip: ${var.iscsi_srv_ip}
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
monitoring_enabled: ${var.monitoring_enabled}
devel_mode: ${var.devel_mode}
qa_mode: ${var.qa_mode}
netweaver_software_bucket: ${var.netweaver_software_bucket}
ascs_instance_number: ${var.ascs_instance_number}
ers_instance_number: ${var.ers_instance_number}
pas_instance_number: ${var.pas_instance_number}
aas_instance_number: ${var.aas_instance_number}
netweaver_product_id: ${var.netweaver_product_id}
netweaver_swpm_folder: ${var.netweaver_swpm_folder}
netweaver_sapcar_exe: ${var.netweaver_sapcar_exe}
netweaver_swpm_sar: ${var.netweaver_swpm_sar}
netweaver_swpm_extract_dir: ${var.netweaver_swpm_extract_dir}
netweaver_sapexe_folder: ${var.netweaver_sapexe_folder}
netweaver_additional_dvds: [${join(", ", formatlist("'%s'", var.netweaver_additional_dvds))}]
netweaver_nfs_share: ${var.netweaver_nfs_share}
nw_inst_disk_device: ${format("%s%s","/dev/disk/by-id/google-", element(google_compute_instance.netweaver.*.attached_disk.0.device_name, count.index))}
hana_ip: ${var.hana_ip}
vpc_network_name: ${var.network_name}
route_table: ${google_compute_route.nw-route[0].name}

EOF
    destination = "/tmp/grains"
  }
}

module "netweaver_provision" {
  source               = "../../../generic_modules/salt_provisioner"
  node_count           = var.provisioner == "salt" ? var.netweaver_count : 0
  instance_ids         = null_resource.netweaver_provisioner.*.id
  user                 = "root"
  private_key_location = var.private_key_location
  public_ips           = google_compute_instance.netweaver.*.network_interface.0.access_config.0.nat_ip
  background           = var.background
}
