locals {
  node_count = var.common_variables["provisioner"] == "salt" ? local.bastion_count : 0
}

resource "null_resource" "wait_after_cloud_init" {
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]
  }
  depends_on = [openstack_compute_instance_v2.bastion]
  connection {
    type        = "ssh"
    user        = var.common_variables["authorized_user"]
    private_key = var.common_variables["bastion_private_key"]
    host        = openstack_compute_floatingip_associate_v2.bastion.floating_ip
  }
}

resource "null_resource" "bastion_provisioner" {
  count = local.node_count

  triggers = {
    bastion_id = join(",", openstack_compute_instance_v2.bastion.*.id)
  }

  connection {
    # host        = element(data.openstack_networking_floatingip_v2.bastion.*.address, count.index)
    host        = openstack_compute_floatingip_associate_v2.bastion.floating_ip
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
data_disk_type: ${var.bastion_data_disk_type}
data_disk_device: /dev/sdb
EOF
    destination = "/tmp/grains"
  }

  depends_on = [null_resource.wait_after_cloud_init]
}

module "bastion_provision" {
  source       = "../../../generic_modules/salt_provisioner"
  node_count   = local.node_count
  instance_ids = null_resource.bastion_provisioner.*.id
  user         = var.common_variables["authorized_user"]
  private_key  = var.common_variables["bastion_private_key"]
  public_ips   = [openstack_compute_floatingip_associate_v2.bastion.floating_ip]
  background   = var.common_variables["background"]
  reboot       = false
}
