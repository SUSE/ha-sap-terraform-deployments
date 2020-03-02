data "template_file" "salt_provisioner" {
  template = file("../salt/salt_provisioner_script.tpl")

  vars = {
    regcode = var.reg_code
  }
}

resource "null_resource" "netweaver_provisioner" {
  count = var.provisioner == "salt" ? var.netweaver_count : 0

  triggers = {
    netweaver_id = join(",", azurerm_virtual_machine.netweaver.*.id)
  }

  # 3 hours should be enough to create netweaver cluster.
  timeouts {
    create = "3h"
  }

  connection {
    host        = data.azurerm_public_ip.netweaver[count.index].ip_address
    type        = "ssh"
    user        = var.admin_user
    private_key = file(var.private_key_location)
  }

  provisioner "file" {
    source      = "../salt"
    destination = "/tmp"
  }

  provisioner "file" {
    content     = data.template_file.salt_provisioner.rendered
    destination = "/tmp/salt_provisioner.sh"
  }

  provisioner "file" {
    content     = <<EOF
provider: azure
role: netweaver_node
name_prefix: vmnetweaver
hostname: vmnetweaver0${count.index + 1}
network_domain: ${var.network_domain}
additional_packages: []
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules), ), )}}
authorized_keys: [${trimspace(file(var.public_key_location))}]
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
virtual_host_ips: [${join(", ", formatlist("'%s'", var.virtual_host_ips))}]
host_ip: ${element(var.host_ips, count.index)}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
shared_storage_type: iscsi
sbd_disk_device: /dev/sdf
iscsi_srv_ip: ${var.iscsi_srv_ip}
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
monitoring_enabled: ${var.monitoring_enabled}
devel_mode: ${var.devel_mode}
qa_mode: ${var.qa_mode}
ascs_instance_number: ${var.ascs_instance_number}
ers_instance_number: ${var.ers_instance_number}
pas_instance_number: ${var.pas_instance_number}
aas_instance_number: ${var.aas_instance_number}
netweaver_nfs_share: ${var.netweaver_nfs_share}
storage_account_name: ${var.storage_account_name}
storage_account_key: ${var.storage_account_key}
storage_account_path: ${var.storage_account_path}

  EOF
    destination = "/tmp/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "${var.background ? "nohup" : ""} sudo sh /tmp/salt_provisioner.sh > /tmp/provisioning.log ${var.background ? "&" : ""}",
      "return_code=$? && sleep 1 && exit $return_code",
    ] # Workaround to let the process start in background properly
  }
}
