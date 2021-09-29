resource "null_resource" "iscsi_provisioner" {
  count = var.common_variables["provisioner"] == "salt" ? var.iscsi_count : 0

  triggers = {
    iscsi_id = libvirt_domain.iscsisrv[count.index].id
  }

  connection {
    host     = libvirt_domain.iscsisrv[count.index].network_interface.0.addresses.0
    user     = "root"
    password = "linux"
  }

  provisioner "file" {
    content = <<EOF
role: iscsi_srv
${var.common_variables["grains_output"]}
name_prefix: ${local.hostname}
hostname: ${local.hostname}${format("%02d", count.index + 1)}
host_ip: ${element(var.host_ips, count.index)}
iscsi_srv_ip: ${element(var.host_ips, count.index)}
iscsidev: /dev/vdb
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
  user         = "root"
  password     = "linux"
  public_ips   = libvirt_domain.iscsisrv.*.network_interface.0.addresses.0
  background   = var.common_variables["background"]
}
