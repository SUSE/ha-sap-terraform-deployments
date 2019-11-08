# Template file to launch the salt provisioning script
data "template_file" "monitoring_salt_provisioner" {
  template = file("../salt/salt_provisioner_script.tpl")

  vars = {
    regcode = var.reg_code
  }
}

resource "null_resource" "monitoring_provisioner" {
  count = var.provisioner == "salt" ? length(libvirt_domain.monitoring_domain) : 0
  triggers = {
    monitoring_id = libvirt_domain.monitoring_domain[count.index].id
  }

  connection {
    host     = libvirt_domain.monitoring_domain[count.index].network_interface.0.addresses.0
    user     = "root"
    password = "linux"
  }

  provisioner "file" {
    source      = "../salt"
    destination = "/tmp"
  }

  provisioner "file" {
    content     = data.template_file.monitoring_salt_provisioner.rendered
    destination = "/tmp/salt_provisioner.sh"
  }

  provisioner "file" {
    content = <<EOF
name_prefix: ${terraform.workspace}-${var.name}
hostname: ${terraform.workspace}-${var.name}
timezone: ${var.timezone}
network_domain: ${var.network_domain}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ",formatlist("'%s': '%s'",keys(var.reg_additional_modules),values(var.reg_additional_modules),),)}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
authorized_keys: [${trimspace(file(var.public_key_location))}]
host_ips: [${join(", ", formatlist("'%s'", [var.monitoring_srv_ip]))}]
host_ip: ${var.monitoring_srv_ip}
role: monitoring
provider: libvirt
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
monitored_hosts: [${join(", ", formatlist("'%s'", var.monitored_hosts))}]
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
