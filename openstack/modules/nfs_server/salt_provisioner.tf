resource "null_resource" "wait_after_cloud_init" {
  count = var.common_variables["provisioner"] == "salt" ? var.nfs_count : 0

  triggers = {
    nfs_id = join(",", openstack_compute_instance_v2.nfssrv.*.id)
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]
  }
  depends_on = [openstack_compute_instance_v2.nfssrv]
  connection {
    host        = element(local.provisioning_addresses, count.index)
    type        = "ssh"
    user        = var.common_variables["authorized_user"]
    private_key = var.common_variables["private_key"]

    bastion_host        = var.bastion_host
    bastion_user        = var.common_variables["authorized_user"]
    bastion_private_key = var.common_variables["bastion_private_key"]

  }
}

resource "null_resource" "nfs_provisioner" {
  count = var.common_variables["provisioner"] == "salt" ? var.nfs_count : 0

  triggers = {
    nfs_id = join(",", openstack_compute_instance_v2.nfssrv.*.id)
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
    content     = <<EOF
role: nfs_srv
${var.common_variables["grains_output"]}
name_prefix: ${local.hostname}
hostname: ${local.hostname}${format("%02d", count.index + 1)}
network_domain: ${var.network_domain}
nfs_srv_ip: ${element(var.host_ips, count.index)}
nfs_mounting_point: ${var.nfs_mounting_point}
hana_scale_out_shared_storage_type: ${var.common_variables["hana"]["scale_out_shared_storage_type"]}
hana_sid: ${var.common_variables["hana"]["sid"]}
hana_instance: ${var.common_variables["hana"]["instance_number"]}
netweaver_sid: ${var.common_variables["netweaver"]["sid"]}
netweaver_ascs_instance: ${var.common_variables["netweaver"]["ascs_instance_number"]}
netweaver_ers_instance: ${var.common_variables["netweaver"]["ers_instance_number"]}
netweaver_shared_storage_type: ${var.common_variables["netweaver"]["shared_storage_type"]}
EOF
    destination = "/tmp/grains"
  }

  depends_on = [null_resource.wait_after_cloud_init]
}

module "nfs_provision" {
  source              = "../../../generic_modules/salt_provisioner"
  node_count          = var.common_variables["provisioner"] == "salt" ? var.nfs_count : 0
  instance_ids        = null_resource.nfs_provisioner.*.id
  user                = var.common_variables["authorized_user"]
  private_key         = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips          = openstack_networking_port_v2.nfssrv.*.fixed_ip.0.ip_address
  background          = var.common_variables["background"]
}
