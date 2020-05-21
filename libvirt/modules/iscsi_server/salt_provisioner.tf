resource "null_resource" "iscsi_provisioner" {
  count = var.provisioner == "salt" ? var.iscsi_count : 0

  triggers = {
    iscsi_id = libvirt_domain.iscsisrv[count.index].id
  }

  connection {
    host     = libvirt_domain.iscsisrv[count.index].network_interface.0.addresses.0
    user     = "root"
    password = "linux"
  }

  provisioner "file" {
    content     = <<EOF
provider: libvirt
role: iscsi_srv
host_ip: ${element(var.host_ips, count.index)}
iscsi_srv_ip: ${element(var.host_ips, count.index)}
iscsidev: /dev/vdb
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
  source       = "../../../generic_modules/salt_provisioner"
  node_count   = var.provisioner == "salt" ? var.iscsi_count : 0
  instance_ids = null_resource.iscsi_provisioner.*.id
  user         = "root"
  password     = "linux"
  public_ips   = libvirt_domain.iscsisrv.*.network_interface.0.addresses.0
  background   = var.background
}
