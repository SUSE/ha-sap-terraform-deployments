data "template_file" "salt_provisioner" {
  template = file("../salt/salt_provisioner_script.tpl")

  vars = {
    regcode = var.reg_code
  }
}

resource "null_resource" "drbd_provisioner" {
  count = var.provisioner == "salt" ? var.drbd_count : 0

  triggers = {
    drbd_id = join(",", google_compute_instance.drbd.*.id)
  }

  connection {
    host = element(
      google_compute_instance.drbd.*.network_interface.0.access_config.0.nat_ip,
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
    source      = "../salt"
    destination = "/tmp"
  }

  provisioner "file" {
    content     = data.template_file.salt_provisioner.rendered
    destination = "/tmp/salt_provisioner.sh"
  }

  provisioner "file" {
    content     = <<EOF
provider: gcp
role: drbd_node
name_prefix: ${terraform.workspace}-drbd
hostname: ${terraform.workspace}-drbd${var.drbd_count > 1 ? "0${count.index + 1}" : ""}
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
drbd_disk_device: /dev/sdb
drbd_cluster_vip: ${var.drbd_cluster_vip}
shared_storage_type: iscsi
sbd_disk_device: /dev/sdd
iscsi_srv_ip: ${var.iscsi_srv_ip}
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
monitoring_enabled: ${var.monitoring_enabled}
devel_mode: ${var.devel_mode}
partitions:
  1:
    start: 0%
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

module "drbd_on_destroy" {
  source               = "../../../generic_modules/on_destroy"
  node_count           = var.provisioner == "salt" ? var.drbd_count : 0
  instance_ids         = google_compute_instance.drbd.*.id
  user                 = "root"
  private_key_location = var.private_key_location
  public_ips           = google_compute_instance.drbd.*.network_interface.0.access_config.0.nat_ip
  dependencies         = []
}
