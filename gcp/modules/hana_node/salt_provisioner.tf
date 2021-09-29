locals {
  gcp_credentials_dest = "/root/google_credentials.json"
}

resource "null_resource" "hana_node_provisioner" {
  count = var.common_variables["provisioner"] == "salt" ? var.hana_count : 0

  triggers = {
    cluster_instance_ids = join(",", google_compute_instance.clusternodes.*.id)
  }

  connection {
    host        = element(local.provisioning_addresses, count.index)
    type        = "ssh"
    user        = var.common_variables["authorized_user"]
    private_key = var.common_variables["private_key"]

    bastion_host        = var.bastion_host
    bastion_user        = var.common_variables["authorized_user"]
    bastion_private_key = var.common_variables["bastion_private_key"]
  }

  provisioner "file" {
    source      = var.gcp_credentials_file
    destination = local.gcp_credentials_dest
  }

  provisioner "file" {
    content     = <<EOF
role: hana_node
${var.common_variables["grains_output"]}
${var.common_variables["hana_grains_output"]}
name_prefix: ${local.hostname}
hostname: ${local.hostname}${format("%02d", count.index + 1)}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
network_domain: ${var.network_domain}
sbd_lun_index: 0
hana_disk_device: ${format("%s%s", "/dev/disk/by-id/google-", element(google_compute_instance.clusternodes.*.attached_disk.0.device_name, count.index))}
hana_backup_device: ${format("%s%s", "/dev/disk/by-id/google-", element(google_compute_instance.clusternodes.*.attached_disk.1.device_name, count.index))}
hana_inst_disk_device: ${format("%s%s", "/dev/disk/by-id/google-", element(google_compute_instance.clusternodes.*.attached_disk.2.device_name, count.index))}
gcp_credentials_file: ${local.gcp_credentials_dest}
vpc_network_name: ${var.network_name}
route_name: ${join(",", google_compute_route.hana-route.*.name)}
route_name_secondary: ${join(",", google_compute_route.hana-route-secondary.*.name)}
iscsi_srv_ip: ${var.iscsi_srv_ip}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
EOF
    destination = "/tmp/grains"
  }
}

module "hana_provision" {
  source              = "../../../generic_modules/salt_provisioner"
  node_count          = var.common_variables["provisioner"] == "salt" ? var.hana_count : 0
  instance_ids        = null_resource.hana_node_provisioner.*.id
  user                = var.common_variables["authorized_user"]
  private_key         = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips          = local.provisioning_addresses
  background          = var.common_variables["background"]
}
