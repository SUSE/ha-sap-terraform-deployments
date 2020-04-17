resource "null_resource" "drbd_provisioner" {
  count = var.provisioner == "salt" ? var.drbd_count : 0

  triggers = {
    iscsi_id = join(",", azurerm_virtual_machine.drbd.*.id)
  }

  connection {
    host        = data.azurerm_public_ip.drbd[count.index].ip_address
    type        = "ssh"
    user        = var.admin_user
    private_key = file(var.private_key_location)
  }

  provisioner "file" {
    content     = <<EOF
provider: azure
role: drbd_node
name_prefix: vm${var.name}
hostname: vm${var.name}${var.drbd_count > 1 ? "0${count.index + 1}" : ""}
network_domain: ${var.network_domain}
additional_packages: []
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules), ), )}}
authorized_keys: [${trimspace(file(var.public_key_location))}]
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
host_ip: ${element(var.host_ips, count.index)}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
drbd_disk_device: /dev/sdc
drbd_cluster_vip: ${var.drbd_cluster_vip}
shared_storage_type: iscsi
sbd_disk_device: /dev/sde
iscsi_srv_ip: ${var.iscsi_srv_ip}
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
monitoring_enabled: ${var.monitoring_enabled}
devel_mode: ${var.devel_mode}
qa_mode: ${var.qa_mode}
partitions:
  1:
    start: 0%
    end: 100%
  EOF
    destination = "/tmp/grains"
  }
}

module "drbd_provision" {
  source               = "../../../generic_modules/salt_provisioner"
  node_count           = var.provisioner == "salt" ? var.drbd_count : 0
  instance_ids         = null_resource.drbd_provisioner.*.id
  user                 = var.admin_user
  private_key_location = var.private_key_location
  public_ips           = data.azurerm_public_ip.drbd.*.ip_address
  background           = var.background
}
