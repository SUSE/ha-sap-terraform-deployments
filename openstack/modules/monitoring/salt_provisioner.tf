resource "null_resource" "wait_after_cloud_init" {
  count = var.common_variables["provisioner"] == "salt" ? local.vm_count : 0

  triggers = {
    monitoring_id = join(",", openstack_compute_instance_v2.monitoring.*.id)
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]
  }
  depends_on = [openstack_compute_instance_v2.monitoring]
  connection {
    host        = element(local.provisioning_addresses, count.index)
    type        = "ssh"
    user        = var.common_variables["authorized_user"]
    private_key = var.common_variables["private_key"]

    bastion_host = var.bastion_host
    bastion_user = var.common_variables["authorized_user"]
    #bastion_user        = "sles"
    bastion_private_key = var.common_variables["bastion_private_key"]

  }
}

resource "null_resource" "monitoring_node_provisioner" {

  count = var.common_variables["provisioner"] == "salt" ? local.vm_count : 0

  triggers = {
    monitoring_id = join(",", openstack_compute_instance_v2.monitoring.*.id)
  }

  connection {
    #host        = local.provisioning_addresses[count.index]
    host = element(local.provisioning_addresses, count.index)
    #host        = var.monitoring_srv_ip
    type        = "ssh"
    user        = var.common_variables["authorized_user"]
    private_key = var.common_variables["private_key"]

    bastion_host        = var.bastion_host
    bastion_user        = var.common_variables["authorized_user"]
    bastion_private_key = var.common_variables["bastion_private_key"]

  }

  provisioner "file" {
    content     = <<EOF
role: monitoring_srv
${var.common_variables["grains_output"]}
${var.common_variables["monitoring_grains_output"]}
name_prefix: ${local.hostname}
hostname: ${local.hostname}
network_domain: ${var.network_domain}
host_ip: ${element(var.host_ips, count.index)}
public_ip: ${var.monitoring_srv_ip}
EOF
    destination = "/tmp/grains"
  }

  depends_on = [null_resource.wait_after_cloud_init]
}

module "monitoring_provision" {
  source              = "../../../generic_modules/salt_provisioner"
  node_count          = var.common_variables["provisioner"] == "salt" ? local.vm_count : 0
  instance_ids        = null_resource.monitoring_node_provisioner.*.id
  user                = var.common_variables["authorized_user"]
  private_key         = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips          = local.provisioning_addresses
  background          = var.common_variables["background"]
}
