# This file contains the salt provisioning logic.
# It will be executed if 'provisioner' is set to 'salt' (default option) and the
# libvirt_domain.domain (netweaver_node) resources are created (check triggers option).

resource "null_resource" "netweaver_node_provisioner" {
  count = var.common_variables["provisioner"] == "salt" ? var.netweaver_count : 0
  triggers = {
    netweaver_ids = libvirt_domain.netweaver_domain[count.index].id
  }

  connection {
    host     = libvirt_domain.netweaver_domain[count.index].network_interface.0.addresses.0
    user     = "root"
    password = "linux"
  }

  provisioner "file" {
    content     = <<EOF
role: netweaver_node
${var.common_variables["grains_output"]}
name_prefix: ${var.name}
hostname: ${var.name}0${count.index + 1}
network_domain: ${var.network_domain}
timezone: ${var.timezone}
authorized_keys: [${trimspace(file(var.common_variables["public_key_location"]))}]
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
virtual_host_ips: [${join(", ", formatlist("'%s'", var.virtual_host_ips))}]
host_ip: ${element(var.host_ips, count.index)}
hana_ip: ${var.hana_ip}
ha_enabled: ${var.ha_enabled}
netweaver_product_id: ${var.netweaver_product_id}
netweaver_inst_media: ${var.netweaver_inst_media}
netweaver_inst_folder: ${var.netweaver_inst_folder}
netweaver_extract_dir: ${var.netweaver_extract_dir}
netweaver_swpm_folder: ${var.netweaver_swpm_folder}
netweaver_sapcar_exe: ${var.netweaver_sapcar_exe}
netweaver_swpm_sar: ${var.netweaver_swpm_sar}
netweaver_sapexe_folder: ${var.netweaver_sapexe_folder}
netweaver_additional_dvds: [${join(", ", formatlist("'%s'", var.netweaver_additional_dvds))}]
netweaver_nfs_share: ${var.netweaver_nfs_share}
ascs_instance_number: ${var.ascs_instance_number}
ers_instance_number: ${var.ers_instance_number}
pas_instance_number: ${var.pas_instance_number}
aas_instance_number: ${var.aas_instance_number}
sbd_enabled: ${var.sbd_enabled}
sbd_storage_type: ${var.sbd_storage_type}
sbd_disk_device: "${var.sbd_storage_type == "shared-disk" ? "/dev/vdb1" : ""}"
sbd_lun_index: 1
iscsi_srv_ip: ${var.iscsi_srv_ip}
EOF
    destination = "/tmp/grains"
  }
}

module "netweaver_provision" {
  source       = "../../../generic_modules/salt_provisioner"
  node_count   = var.common_variables["provisioner"] == "salt" ? var.netweaver_count : 0
  instance_ids = null_resource.netweaver_node_provisioner.*.id
  user         = "root"
  password     = "linux"
  public_ips   = libvirt_domain.netweaver_domain.*.network_interface.0.addresses.0
  background   = var.common_variables["background"]
}
