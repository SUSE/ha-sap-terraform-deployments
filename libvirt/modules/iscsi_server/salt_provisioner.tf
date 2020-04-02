# Template file to launch the salt provisioning script
data "template_file" "salt_provisioner" {
  template = file("../salt/salt_provisioner_script.tpl")

  vars = {
    regcode = var.reg_code
  }
}

resource "null_resource" "iscsi_provisioner" {
  count = var.provisioner == "salt" ? var.iscsi_count : 0

  triggers = {
    iscsi_id = libvirt_domain.iscsisrv[count.index].id
  }

  connection {
    host     = libvirt_domain.iscsisrv[count.index].network_interface.0.addresses.0
    user     = "root"
    password = "linux"
  }

  provisioner "file" {
    source      = "../salt"
    destination = "/tmp/salt"
  }

  provisioner "file" {
    content     = data.template_file.salt_provisioner.rendered
    destination = "/tmp/salt_provisioner.sh"
  }

  provisioner "file" {
    content = <<EOF
provider: libvirt
role: iscsi_srv
host_ip: ${var.iscsi_srv_ip}
iscsi_srv_ip: ${var.iscsi_srv_ip}
iscsidev: ${var.iscsidev}
iscsi_disks: ${var.iscsi_disks}
qa_mode: ${var.qa_mode}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules)))}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}

partitions:
  1:
    start: 1
    end: 33%
  2:
    start: 33%
    end: 67%
  3:
    start: 67%
    end: 100%

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

module "iscsi_on_destroy" {
  source       = "../../../generic_modules/on_destroy"
  node_count   = var.provisioner == "salt" ? var.iscsi_count : 0
  instance_ids = libvirt_domain.iscsisrv.*.id
  user         = "root"
  password     = "linux"
  public_ips   = libvirt_domain.iscsisrv.*.network_interface.0.addresses.0
  dependencies = [libvirt_domain.iscsisrv]
}
