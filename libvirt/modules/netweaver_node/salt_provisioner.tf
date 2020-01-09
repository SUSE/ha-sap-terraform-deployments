# This file contains the salt provisioning logic.
# It will be executed if 'provisioner' is set to 'salt' (default option) and the
# libvirt_domain.domain (netweaver_node) resources are created (check triggers option).

# Template file to launch the salt provisioning script
data "template_file" "netweaver_salt_provisioner" {
  template = file("../salt/salt_provisioner_script.tpl")

  vars = {
    regcode = var.reg_code
  }
}

resource "null_resource" "netweaver_node_provisioner" {
  count = var.provisioner == "salt" ? var.netweaver_count : 0
  triggers = {
    netweaver_ids = libvirt_domain.netweaver_domain[count.index].id
  }

  connection {
    host     = libvirt_domain.netweaver_domain[count.index].network_interface.0.addresses.0
    user     = "root"
    password = "linux"
  }

  provisioner "file" {
    source      = "../salt"
    destination = "/tmp"
  }

  provisioner "file" {
    content     = data.template_file.netweaver_salt_provisioner.rendered
    destination = "/tmp/salt_provisioner.sh"
  }

  provisioner "file" {
content = <<EOF
name_prefix: ${var.name}
hostname: ${var.name}${var.netweaver_count > 1 ? "0${count.index + 1}" : ""}
network_domain: ${var.network_domain}
timezone: ${var.timezone}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ",formatlist("'%s': '%s'",keys(var.reg_additional_modules),values(var.reg_additional_modules),),)}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
authorized_keys: [${trimspace(file(var.public_key_location))}]
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
virtual_host_ips: [${join(", ", formatlist("'%s'", var.virtual_host_ips))}]
host_ip: ${element(var.host_ips, count.index)}
provider: libvirt
role: netweaver_node
netweaver_inst_media: ${var.netweaver_inst_media}
netweaver_nfs_share: ${var.netweaver_nfs_share}
ascs_instance_number: ${var.ascs_instance_number}
ers_instance_number: ${var.ers_instance_number}
pas_instance_number: ${var.pas_instance_number}
aas_instance_number: ${var.aas_instance_number}
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
shared_storage_type: shared-disk
sbd_disk_device: /dev/vdb1
monitoring_enabled: ${var.monitoring_enabled}
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
