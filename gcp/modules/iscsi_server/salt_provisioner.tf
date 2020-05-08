resource "null_resource" "iscsi_provisioner" {
  count = var.provisioner == "salt" ? var.iscsi_count : 0

  triggers = {
    iscsi_id = join(",", google_compute_instance.iscsisrv.*.id)
  }

  connection {
    host        = element(google_compute_instance.iscsisrv.*.network_interface.0.access_config.0.nat_ip, count.index)
    type        = "ssh"
    user        = "root"
    private_key = file(var.private_key_location)
  }

  provisioner "file" {
    content = <<EOF
provider: gcp
role: iscsi_srv
iscsi_srv_ip: ${element(google_compute_instance.iscsisrv.*.network_interface.0.network_ip, count.index)}
iscsidev: ${format("%s%s","/dev/disk/by-id/google-", element(google_compute_instance.iscsisrv.*.attached_disk.0.device_name, count.index))}
qa_mode: ${var.qa_mode}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules)))}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
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
  node_count           = var.provisioner == "salt" ? var.iscsi_count : 0
  instance_ids         = null_resource.iscsi_provisioner.*.id
  user                 = "root"
  private_key_location = var.private_key_location
  public_ips           = google_compute_instance.iscsisrv.*.network_interface.0.access_config.0.nat_ip
  background           = var.background
}
