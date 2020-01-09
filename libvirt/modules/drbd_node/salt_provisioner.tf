# This file contains the salt provisioning logic.
# It will be executed if 'provisioner' is set to 'salt' (default option) and the
# libvirt_domain.domain (drbd_node) resources are created (check triggers option).

# Template file to launch the salt provisioning script
data "template_file" "drbd_salt_provisioner" {
  template = file("../salt/salt_provisioner_script.tpl")

  vars = {
    regcode = var.reg_code
  }
}

resource "null_resource" "drbd_node_provisioner" {
  count = var.provisioner == "salt" ? var.drbd_count : 0
  triggers = {
    drbd_ids = libvirt_domain.drbd_domain[count.index].id
  }

  connection {
    host     = libvirt_domain.drbd_domain[count.index].network_interface.0.addresses.0
    user     = "root"
    password = "linux"
  }

  provisioner "file" {
    source      = "../salt"
    destination = "/tmp"
  }

  provisioner "file" {
    content     = data.template_file.drbd_salt_provisioner.rendered
    destination = "/tmp/salt_provisioner.sh"
  }

  provisioner "file" {
    content = <<EOF
name_prefix: ${terraform.workspace}-${var.name}
hostname: ${terraform.workspace}-${var.name}${var.drbd_count > 1 ? "0${count.index + 1}" : ""}
network_domain: ${var.network_domain}
timezone: ${var.timezone}
reg_code: ${var.reg_code}
devel_mode: ${var.devel_mode}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ",formatlist("'%s': '%s'",keys(var.reg_additional_modules),values(var.reg_additional_modules),),)}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
authorized_keys: [${trimspace(file(var.public_key_location))}]
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
host_ip: ${element(var.host_ips, count.index)}
provider: libvirt
role: drbd_node
drbd_disk_device: /dev/vdb
shared_storage_type: ${var.shared_storage_type}
sbd_disk_device: "${var.shared_storage_type == "iscsi" ? "/dev/sda" : "/dev/vdc"}"
iscsi_srv_ip: ${var.iscsi_srv_ip}
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
monitoring_enabled: ${var.monitoring_enabled}
partitions:
  1:
    start: 0%
    end: 100%


EOF
  destination = "/tmp/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "${var.background ? "nohup" : ""} sh /tmp/salt_provisioner.sh > /tmp/provisioning.log ${var.background ? "&" : ""}",
      "return_code=$? && sleep 1 && exit $return_code",
    ] # Workaround to let the process start in background properly
  }
}
