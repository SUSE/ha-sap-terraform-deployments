locals {
  node_count = var.common_variables["provisioner"] == "salt" ? local.bastion_count : 0
}

resource "null_resource" "bastion_provisioner" {
  count = local.node_count

  triggers = {
    bastion_id = ibm_pi_instance.bastion[count.index].instance_id
  }

  connection {
    host        = element(data.ibm_pi_instance_ip.bastion_public.*.external_ip, count.index)
    type        = "ssh"
    user        = var.common_variables["authorized_user"]
    private_key = var.common_variables["bastion_private_key"]
  }

  provisioner "file" {
    content     = <<EOF
role: bastion
${var.common_variables["grains_output"]}
EOF
    destination = "/tmp/grains"
  }

  # Sets up bastion SNAT router - https://cloud.ibm.com/docs/power-iaas?topic=power-iaas-using-linux#linux-networking
  provisioner "remote-exec" {
  inline = [
    "echo 'net.ipv4.ip_forward = 1' > /etc/sysctl.d/powervs-snat.conf",
    "/sbin/sysctl --system",
    "grep '^iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE$' /etc/init.d/after.local || echo 'iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE' >> /etc/init.d/after.local",
    "/usr/sbin/iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE >/dev/null 2>&1 || /usr/sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"
    ]
  }
}

module "bastion_provision" {
  source               = "../../../generic_modules/salt_provisioner"
  node_count           = local.node_count
  instance_ids         = null_resource.bastion_provisioner.*.id
  user                 = var.common_variables["authorized_user"]
  private_key          = var.common_variables["bastion_private_key"]
  public_ips           = data.ibm_pi_instance_ip.bastion_public.*.external_ip
  background           = var.common_variables["background"]
  reboot               = false
}
