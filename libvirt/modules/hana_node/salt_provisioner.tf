# This file contains the salt provisioning logic.
# It will be executed if 'provisioner' is set to 'salt' (default option) and the
# libvirt_domain.domain (hana_node) resources are created (check triggers option).

resource "null_resource" "wait_after_cloud_init" {
  count = var.common_variables["provisioner"] == "salt" ? var.hana_count : 0

  triggers = {
    hana_ids = libvirt_domain.hana_domain[count.index].id
  }

  provisioner "remote-exec" {
    inline = [
      "if which cloud-init; then cloud-init status --wait; else echo no cloud-init installed; fi"
    ]
  }

  connection {
    host     = libvirt_domain.hana_domain[count.index].network_interface.0.addresses.0
    user     = "root"
    password = "linux"
  }
}

resource "null_resource" "hana_node_provisioner" {
  count = var.common_variables["provisioner"] == "salt" ? var.hana_count : 0
  triggers = {
    hana_ids = libvirt_domain.hana_domain[count.index].id
  }

  connection {
    host     = libvirt_domain.hana_domain[count.index].network_interface.0.addresses.0
    user     = "root"
    password = "linux"
  }

  provisioner "file" {
    content     = <<EOF
role: hana_node
${var.common_variables["grains_output"]}
${var.common_variables["hana_grains_output"]}
name_prefix: ${local.hostname}
hostname: ${local.hostname}${format("%02d", count.index + 1)}
network_domain: ${var.network_domain}
timezone: ${var.timezone}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
host_ip: ${element(var.host_ips, count.index)}
hana_data_disks_configuration: {${join(", ", formatlist("'%s': '%s'", keys(var.hana_data_disks_configuration), values(var.hana_data_disks_configuration), ), formatlist("'%s': '%s'", "devices", var.block_devices), )}}
sbd_disk_device: "${var.common_variables["hana"]["sbd_storage_type"] == "shared-disk" ? "/dev/vdb" : ""}"
sbd_lun_index: 0
iscsi_srv_ip: ${var.iscsi_srv_ip}
nfs_mount_ip:
  ${local.shared_storage_nfs == 1 && !contains(split("#", lookup(var.hana_data_disks_configuration, "names", "")), "shared") ? "shared: [ ${element(split(":", var.scale_out_nfs), 0)}, ${element(split(":", var.scale_out_nfs), 0)} ]" : ""}
nfs_mount_dir:
  ${local.shared_storage_nfs == 1 && !contains(split("#", lookup(var.hana_data_disks_configuration, "names", "")), "shared") ? "shared: [ ${format("%s%s", element(split(":", var.scale_out_nfs), 1), "/site_1/shared")}, ${format("%s%s", element(split(":", var.scale_out_nfs), 1), "/site_2/shared")} ]" : ""}
node_count: ${var.hana_count + local.create_scale_out}
EOF
    destination = "/tmp/grains"
  }

  depends_on = [null_resource.wait_after_cloud_init]
}

module "hana_provision" {
  source       = "../../../generic_modules/salt_provisioner"
  node_count   = var.common_variables["provisioner"] == "salt" ? var.hana_count : 0
  instance_ids = null_resource.hana_node_provisioner.*.id
  user         = "root"
  password     = "linux"
  public_ips   = libvirt_domain.hana_domain.*.network_interface.0.addresses.0
  background   = var.common_variables["background"]
}
