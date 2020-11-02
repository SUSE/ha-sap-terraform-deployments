resource "null_resource" "iscsi_provisioner" {
  count = var.common_variables["provisioner"] == "salt" ? var.iscsi_count : 0

  triggers = {
    iscsi_id = join(",", google_compute_instance.iscsisrv.*.id)
  }

  connection {
    host        = element(google_compute_instance.iscsisrv.*.network_interface.0.access_config.0.nat_ip, count.index)
    type        = "ssh"
    user        = "root"
    private_key = var.common_variables["private_key"]
  }

  provisioner "file" {
    content = <<EOF
role: iscsi_srv
${var.common_variables["grains_output"]}
iscsi_srv_ip: ${element(google_compute_instance.iscsisrv.*.network_interface.0.network_ip, count.index)}
iscsidev: ${format("%s%s","/dev/disk/by-id/google-", element(google_compute_instance.iscsisrv.*.attached_disk.0.device_name, count.index))}
${yamlencode(
  {partitions: {for index in range(var.lun_count) :
    tonumber(index+1) => {
      start: format("%.0f%%", index*100/var.lun_count),
      end: format("%.0f%%", (index+1)*100/var.lun_count)
    }
  }}
)}

EOF
destination = "/tmp/grains"
}
}

module "iscsi_provision" {
  source               = "../../../generic_modules/salt_provisioner"
  node_count           = var.common_variables["provisioner"] == "salt" ? var.iscsi_count : 0
  instance_ids         = null_resource.iscsi_provisioner.*.id
  user                 = "root"
  private_key          = var.common_variables["private_key"]
  public_ips           = google_compute_instance.iscsisrv.*.network_interface.0.access_config.0.nat_ip
  background           = var.common_variables["background"]
}
