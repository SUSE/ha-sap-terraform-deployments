resource "null_resource" "wait_after_cloud_init" {
  count = var.common_variables["provisioner"] == "salt" ? var.iscsi_count : 0

  triggers = {
    iscsi_id = join(",", openstack_compute_instance_v2.iscsisrv.*.id)
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]
  }
  depends_on = [openstack_compute_instance_v2.iscsisrv]
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

resource "null_resource" "iscsi_provisioner" {
  count = var.common_variables["provisioner"] == "salt" ? var.iscsi_count : 0

  triggers = {
    iscsi_id = join(",", openstack_compute_instance_v2.iscsisrv.*.id)
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
    content = <<EOF
role: iscsi_srv
${var.common_variables["grains_output"]}
name_prefix: ${local.hostname}
hostname: ${local.hostname}${format("%02d", count.index + 1)}
network_domain: ${var.network_domain}
iscsi_srv_ip: ${element(var.host_ips, count.index)}
iscsidev: /dev/sdb
${yamlencode(
    { partitions : { for index in range(var.lun_count) :
      tonumber(index + 1) => {
        start : format("%.0f%%", index * 100 / var.lun_count),
        end : format("%.0f%%", (index + 1) * 100 / var.lun_count)
      }
    } }
)}

EOF
destination = "/tmp/grains"
}

depends_on = [null_resource.wait_after_cloud_init]
}

module "iscsi_provision" {
  source              = "../../../generic_modules/salt_provisioner"
  node_count          = var.common_variables["provisioner"] == "salt" ? var.iscsi_count : 0
  instance_ids        = null_resource.iscsi_provisioner.*.id
  user                = var.common_variables["authorized_user"]
  private_key         = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips          = openstack_networking_port_v2.iscsisrv.*.fixed_ip.0.ip_address
  background          = var.common_variables["background"]
}
