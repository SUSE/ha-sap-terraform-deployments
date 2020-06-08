resource "null_resource" "iscsi_provisioner" {
  count = var.provisioner == "salt" ? var.iscsi_count : 0

  triggers = {
    iscsi_id = join(",", azurerm_virtual_machine.iscsisrv.*.id)
  }

  connection {
    host        = element(local.provisioning_addresses, count.index)
    type        = "ssh"
    user        = var.admin_user
    private_key = file(var.private_key_location)

    bastion_host        = var.bastion_host
    bastion_user        = var.admin_user
    bastion_private_key = file(var.private_key_location)
  }

  provisioner "file" {
    content     = <<EOF
provider: azure
role: iscsi_srv
iscsi_srv_ip: ${element(var.host_ips, count.index)}
iscsidev: /dev/sdc
qa_mode: ${var.qa_mode}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules), ), )}}
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
  user                 = var.admin_user
  private_key_location = var.private_key_location
  bastion_host         = var.bastion_host
  public_ips           = local.provisioning_addresses
  background           = var.background
}
