# This file contains the salt provisioning logic.
# It will be executed if 'provisioner' is set to 'salt' (default option) and the
# libvirt_domain.domain (hana_node) resources are created (check triggers option).

# Template file to launch the salt provisioning script
data "template_file" "salt_provisioner" {
  template = file("../salt/salt_provisioner_script.tpl")

  vars = {
    regcode = var.reg_code
  }
}

resource "null_resource" "host_provisioner" {
  count = var.provisioner == "salt" ? length(libvirt_domain.domain) : 0

  triggers = {
    cluster_instance_ids = join(",", libvirt_domain.domain.*.id)
  }

  connection {
    host = element(
      libvirt_domain.domain.*.network_interface.0.addresses.0,
      count.index,
    )
    user     = "root"
    password = "linux"
  }

  provisioner "file" {
    source      = "../../salt"
    destination = "/tmp"
  }

  provisioner "file" {
    content     = data.template_file.salt_provisioner.rendered
    destination = "/tmp/salt_provisioner.sh"
  }

  provisioner "file" {
    content = <<EOF

name_prefix: ${terraform.workspace}-${var.name}
hostname: ${terraform.workspace}-${var.name}${var.host_count > 1 ? "0${count.index + 1}" : ""}
domain: ${var.base_configuration["domain"]}
timezone: ${var.base_configuration["timezone"]}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ",formatlist("'%s': '%s'",keys(var.reg_additional_modules),values(var.reg_additional_modules),),)}}
additional_repos: {${join(", ",formatlist("'%s': '%s'",keys(var.additional_repos),values(var.additional_repos),),)}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
authorized_keys: [${trimspace(file(var.base_configuration["public_key_location"]))},${trimspace(file(var.public_key_location))}]
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
host_ip: ${element(var.host_ips, count.index)}
${var.grains}

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
