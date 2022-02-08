locals {
  node_count = var.common_variables["provisioner"] == "salt" ? 1 : 0
}

resource "null_resource" "bastion_provisioner" {
  count = local.node_count

  triggers = {
    bastion_id = join(",", azurerm_virtual_machine.bastion.*.id)
  }

  connection {
    host        = local.public_ip_address
    type        = "ssh"
    user        = var.common_variables["authorized_user"]
    private_key = var.common_variables["bastion_private_key"]
    # on fortinet, a default timeout of 5m is not enough to bootstrap everything
    timeout = "60m"
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
  public_ips   = [local.public_ip_address]
  background   = var.common_variables["background"]
  reboot       = false
}
