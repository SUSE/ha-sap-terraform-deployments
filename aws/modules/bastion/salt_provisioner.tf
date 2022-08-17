resource "null_resource" "bastion_provisioner" {
  count = var.common_variables["provisioner"] == "salt" ? var.bastion_count : 0

  triggers = {
    bastion_id = join(",", aws_instance.bastion.*.id)
  }

  connection {
    host        = element(local.provisioning_addresses, count.index)
    type        = "ssh"
    user        = var.common_variables["authorized_user"]
    private_key = var.common_variables["bastion_private_key"]
  }

  provisioner "file" {
    content     = <<EOF
role: bastion_srv
${var.common_variables["grains_output"]}
name_prefix: ${local.hostname}
hostname: ${local.hostname}
network_domain: ${var.network_domain}
region: ${var.aws_region}

EOF
    destination = "/tmp/grains"
  }
}

module "bastion_provision" {
  source       = "../../../generic_modules/salt_provisioner"
  node_count   = var.common_variables["provisioner"] == "salt" ? var.bastion_count : 0
  instance_ids = null_resource.bastion_provisioner.*.id
  user         = var.common_variables["authorized_user"]
  private_key  = var.common_variables["private_key"]
  public_ips   = local.provisioning_addresses
  background   = var.common_variables["background"]
}
