resource "null_resource" "drbd_provisioner" {
  count = var.common_variables["provisioner"] == "salt" ? var.drbd_count : 0

  triggers = {
    drbd_id = join(",", google_compute_instance.drbd.*.id)
  }

  connection {
    host = element(
      google_compute_instance.drbd.*.network_interface.0.access_config.0.nat_ip,
      count.index,
    )
    type        = "ssh"
    user        = "root"
    private_key = file(var.common_variables["private_key_location"])
  }

  provisioner "file" {
    content     = <<EOF
role: drbd_node
${var.common_variables["grains_output"]}
name_prefix: ${terraform.workspace}-drbd
hostname: ${terraform.workspace}-drbd0${count.index + 1}
network_domain: ${var.network_domain}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
host_ip: ${element(var.host_ips, count.index)}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
drbd_disk_device: ${format("%s%s","/dev/disk/by-id/google-", element(google_compute_instance.drbd.*.attached_disk.0.device_name, count.index))}
drbd_cluster_vip: ${var.drbd_cluster_vip}
fencing_mechanism: ${var.fencing_mechanism}
sbd_storage_type: ${var.sbd_storage_type}
sbd_lun_index: 2
iscsi_srv_ip: ${var.iscsi_srv_ip}
nfs_mounting_point: ${var.nfs_mounting_point}
nfs_export_name: ${var.nfs_export_name}
vpc_network_name: ${var.network_name}
route_name: ${google_compute_route.drbd-route[0].name}
partitions:
  1:
    start: 0%
    end: 100%

  EOF
    destination = "/tmp/grains"
  }
}

module "drbd_provision" {
  source               = "../../../generic_modules/salt_provisioner"
  node_count           = var.common_variables["provisioner"] == "salt" ? var.drbd_count : 0
  instance_ids         = null_resource.drbd_provisioner.*.id
  user                 = "root"
  private_key_location = var.common_variables["private_key_location"]
  public_ips           = google_compute_instance.drbd.*.network_interface.0.access_config.0.nat_ip
  background           = var.common_variables["background"]
}
