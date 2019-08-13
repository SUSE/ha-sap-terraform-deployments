# This file contains the salt provisioning logic.
# It will be executed if 'provisioner' is set to salt (default option) and the
# iscsi and hana node resources are created (check triggers option).

terraform {
  required_version = ">= 0.12"
}

# Template file to launch the salt provisioing script
data "template_file" "salt_provisioner" {
  template = file("../../salt/salt_provisioner_script.tpl")

  vars = {
    regcode = var.reg_code
  }
}

resource "null_resource" "iscsi_provisioner" {
  count = var.provisioner == "salt" ? 1 : 0

  triggers = {
    iscsi_id = join(",", google_compute_instance.iscsisrv.*.id)
  }

  connection {
    host        = google_compute_instance.iscsisrv.network_interface[0].access_config[0].nat_ip
    type        = "ssh"
    user        = "root"
    private_key = file(var.private_key_location)
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
provider: gcp
role: iscsi_srv
iscsi_srv_ip: ${var.iscsi_ip}
iscsidev: ${var.iscsidev}
qa_mode: ${var.qa_mode}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules)))}}
additional_repos: {${join(", ", formatlist("'%s': '%s'", keys(var.additional_repos), values(var.additional_repos)))}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}

partitions:
  1:
    start: 1
    end: 20%
  2:
    start: 20%
    end: 40%
  3:
    start: 40%
    end: 60%
  4:
    start: 60%
    end: 80%
  5:
    start: 80%
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

resource "null_resource" "hana_node_provisioner" {
  count = var.provisioner == "salt" ? length(google_compute_instance.clusternodes) : 0

  triggers = {
    cluster_instance_ids = join(",", google_compute_instance.clusternodes.*.id)
  }

  connection {
    host = element(
      google_compute_instance.clusternodes.*.network_interface.0.access_config.0.nat_ip,
      count.index,
    )
    type        = "ssh"
    user        = "root"
    private_key = file(var.private_key_location)
  }

  provisioner "file" {
    source      = var.gcp_credentials_file
    destination = "/root/google_credentials.json"
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
provider: gcp
role: hana_node
scenario_type: ${var.scenario_type}
name_prefix: ${terraform.workspace}-${var.name}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
hostname: ${terraform.workspace}-${var.name}${var.ninstances > 1 ? "0${count.index + 1}" : ""}
domain: "tf.local"
shared_storage_type: iscsi
sbd_disk_device: /dev/sdd
hana_inst_folder: ${var.hana_inst_folder}
hana_disk_device: ${var.hana_disk_device}
hana_inst_disk_device: ${var.hana_inst_disk_device}
hana_fstype: ${var.hana_fstype}
gcp_credentials_file: ${var.gcp_credentials_file}
sap_hana_deployment_bucket: ${var.sap_hana_deployment_bucket}
iscsi_srv_ip: ${var.iscsi_ip}
init_type: ${var.init_type}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
qa_mode: ${var.qa_mode}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules)))}}
additional_repos: {${join(", ", formatlist("'%s': '%s'", keys(var.additional_repos), values(var.additional_repos)))}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
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

