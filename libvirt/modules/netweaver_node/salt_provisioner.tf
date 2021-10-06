# This file contains the salt provisioning logic.
# It will be executed if 'provisioner' is set to 'salt' (default option) and the
# libvirt_domain.domain (netweaver_node) resources are created (check triggers option).

resource "null_resource" "netweaver_node_provisioner" {
  count = var.common_variables["provisioner"] == "salt" ? local.vm_count : 0
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
${var.common_variables["netweaver_grains_output"]}
name_prefix: ${local.hostname}
hostname: ${local.hostname}${format("%02d", count.index + 1)}
network_domain: ${var.network_domain}
timezone: ${var.timezone}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
virtual_host_ips: [${join(", ", formatlist("'%s'", var.virtual_host_ips))}]
host_ip: ${element(var.host_ips, count.index)}
app_server_count: ${var.app_server_count}
netweaver_inst_media: ${var.netweaver_inst_media}
sbd_disk_device: "${var.common_variables["netweaver"]["sbd_storage_type"] == "shared-disk" ? "/dev/vdb1" : ""}"
sbd_lun_index: 1
iscsi_srv_ip: ${var.iscsi_srv_ip}
EOF
    destination = "/tmp/grains"
  }
}

module "netweaver_provision" {
  source       = "../../../generic_modules/salt_provisioner"
  node_count   = var.common_variables["provisioner"] == "salt" ? local.vm_count : 0
  instance_ids = null_resource.netweaver_node_provisioner.*.id
  user         = "root"
  password     = "linux"
  public_ips   = libvirt_domain.netweaver_domain.*.network_interface.0.addresses.0
  background   = var.common_variables["background"]
}
