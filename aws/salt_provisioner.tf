# This file contains the salt provisioning logic.
# It will be executed if 'provisioner' is set to salt (default option) and the
# iscsi and hana node resources are created (check triggers option).

resource "null_resource" "iscsi_provisioner" {
  count = var.provisioner == "salt" ? 1 : 0

  triggers = {
    iscsi_id = join(",", aws_instance.iscsisrv.*.id)
  }

  connection {
    host        = element(aws_instance.iscsisrv.*.public_ip, count.index)
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.private_key_location)
  }

  provisioner "file" {
    source      = "../salt"
    destination = "/tmp/salt"
  }

  provisioner "file" {
    content = <<EOF
provider: aws
role: iscsi_srv
iscsi_srv_ip: ${aws_instance.iscsisrv.private_ip}
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
      "${var.background ? "nohup" : ""} sudo sh /tmp/salt/provision.sh > /tmp/provisioning.log ${var.background ? "&" : ""}",
      "return_code=$? && sleep 1 && exit $return_code",
    ] # Workaround to let the process start in background properly
  }
}
