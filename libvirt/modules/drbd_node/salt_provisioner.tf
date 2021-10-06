# This file contains the salt provisioning logic.
# It will be executed if 'provisioner' is set to 'salt' (default option) and the
# libvirt_domain.domain (drbd_node) resources are created (check triggers option).

resource "null_resource" "drbd_node_provisioner" {
  count = var.common_variables["provisioner"] == "salt" ? var.drbd_count : 0
  triggers = {
    drbd_ids = libvirt_domain.drbd_domain[count.index].id
  }

  connection {
    host     = libvirt_domain.drbd_domain[count.index].network_interface.0.addresses.0
    user     = "root"
    password = "linux"
  }

  provisioner "file" {
    content     = <<EOF
role: drbd_node
${var.common_variables["grains_output"]}
name_prefix: ${local.hostname}
hostname: ${local.hostname}${format("%02d", count.index + 1)}
network_domain: ${var.network_domain}
timezone: ${var.timezone}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
host_ip: ${element(var.host_ips, count.index)}
drbd_cluster_vip: ${var.drbd_cluster_vip}
drbd_disk_device: /dev/vdb
fencing_mechanism: ${var.fencing_mechanism}
sbd_storage_type: ${var.sbd_storage_type}
sbd_disk_device: "${var.sbd_storage_type == "shared-disk" ? "/dev/vdc" : ""}"
sbd_lun_index: 2
iscsi_srv_ip: ${var.iscsi_srv_ip}
nfs_mounting_point: ${var.nfs_mounting_point}
nfs_export_name: ${var.nfs_export_name}
partitions:
  1:
    start: 0%
    end: 100%
EOF
    destination = "/tmp/grains"
  }
}

module "drbd_provision" {
  source       = "../../../generic_modules/salt_provisioner"
  node_count   = var.common_variables["provisioner"] == "salt" ? var.drbd_count : 0
  instance_ids = null_resource.drbd_node_provisioner.*.id
  user         = "root"
  password     = "linux"
  public_ips   = libvirt_domain.drbd_domain.*.network_interface.0.addresses.0
  background   = var.common_variables["background"]
}
