resource "null_resource" "iscsi_provisioner" {
  count = var.common_variables["provisioner"] == "salt" ? var.iscsi_count : 0

  triggers = {
    iscsi_id = join(",", aws_instance.iscsisrv.*.id)
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
region: ${var.aws_region}
iscsi_srv_ip: ${element(aws_instance.iscsisrv.*.private_ip, count.index)}
iscsidev: /dev/nvme1n1
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
}

module "iscsi_provision" {
  source       = "../../../generic_modules/salt_provisioner"
  node_count   = var.common_variables["provisioner"] == "salt" ? var.iscsi_count : 0
  instance_ids = null_resource.iscsi_provisioner.*.id
  user                = var.common_variables["authorized_user"]
  private_key  = var.common_variables["private_key"]
  public_ips   = local.provisioning_addresses
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  background   = var.common_variables["background"]
}
