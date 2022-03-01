locals {
  node_count = var.common_variables["provisioner"] == "salt" ? local.bastion_count : 0
}

resource "null_resource" "bastion_provisioner" {
  count = local.node_count

  triggers = {
    bastion_id = join(",", azurerm_virtual_machine.bastion.*.id)
  }

  connection {
    host        = element(data.azurerm_public_ip.bastion.*.ip_address, count.index)
    type        = "ssh"
    user        = var.common_variables["authorized_user"]
    private_key = var.common_variables["bastion_private_key"]
  }

  provisioner "file" {
    content     = <<EOF
role: bastion
${var.common_variables["grains_output"]}
name_prefix: ${local.hostname}
hostname: ${local.hostname}
network_domain: ${var.network_domain}
EOF
    destination = "/tmp/grains"
  }
}

module "bastion_provision" {
  source       = "../../../generic_modules/salt_provisioner"
  node_count   = local.node_count
  instance_ids = null_resource.bastion_provisioner.*.id
  user         = var.common_variables["authorized_user"]
  private_key  = var.common_variables["bastion_private_key"]
  public_ips   = data.azurerm_public_ip.bastion.*.ip_address
  background   = var.common_variables["background"]
  reboot       = false
}
