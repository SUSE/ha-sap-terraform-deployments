# This file contains the salt provisioning logic.
# It will be executed if 'provisioner' is set to 'salt' (default option) and the
# libvirt_domain.domain (netweaver_node) resources are created (check triggers option).

resource "null_resource" "netweaver_node_provisioner" {
  count = var.provisioner == "salt" ? var.netweaver_count : 0
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
name_prefix: ${var.name}
hostname: ${var.name}0${count.index + 1}
network_domain: ${var.network_domain}
timezone: ${var.timezone}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules), ), )}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
authorized_keys: [${trimspace(file(var.public_key_location))}]
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
virtual_host_ips: [${join(", ", formatlist("'%s'", var.virtual_host_ips))}]
host_ip: ${element(var.host_ips, count.index)}
hana_ip: ${var.hana_ip}
provider: libvirt
role: netweaver_node
netweaver_product_id: ${var.netweaver_product_id}
netweaver_inst_media: ${var.netweaver_inst_media}
netweaver_swpm_folder: ${var.netweaver_swpm_folder}
netweaver_sapcar_exe: ${var.netweaver_sapcar_exe}
netweaver_swpm_sar: ${var.netweaver_swpm_sar}
netweaver_swpm_extract_dir: ${var.netweaver_swpm_extract_dir}
netweaver_sapexe_folder: ${var.netweaver_sapexe_folder}
netweaver_additional_dvds: [${join(", ", formatlist("'%s'", var.netweaver_additional_dvds))}]
netweaver_nfs_share: ${var.netweaver_nfs_share}
ascs_instance_number: ${var.ascs_instance_number}
ers_instance_number: ${var.ers_instance_number}
pas_instance_number: ${var.pas_instance_number}
aas_instance_number: ${var.aas_instance_number}
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
shared_storage_type: shared-disk
sbd_disk_device: /dev/vdb1
monitoring_enabled: ${var.monitoring_enabled}
devel_mode: ${var.devel_mode}
EOF
    destination = "/tmp/grains"
  }
}

module "netweaver_provision" {
  source       = "../../../generic_modules/salt_provisioner"
  node_count   = var.provisioner == "salt" ? var.netweaver_count : 0
  instance_ids = null_resource.netweaver_node_provisioner.*.id
  user         = "root"
  password     = "linux"
  public_ips   = libvirt_domain.netweaver_domain.*.network_interface.0.addresses.0
  background   = var.background
}
