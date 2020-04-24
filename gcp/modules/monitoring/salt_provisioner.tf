resource "null_resource" "monitoring_provisioner" {
  count = var.provisioner == "salt" && var.monitoring_enabled ? 1 : 0

  triggers = {
    cluster_instance_id = google_compute_instance.monitoring.0.id
  }

  connection {
    host        = google_compute_instance.monitoring.0.network_interface.0.access_config.0.nat_ip
    type        = "ssh"
    user        = "root"
    private_key = file(var.private_key_location)
  }

  provisioner "file" {
    content     = <<EOF
provider: gcp
role: monitoring
name_prefix: ${terraform.workspace}-monitoring
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
hostname: ${terraform.workspace}-monitoring
network_domain: "tf.local"
host_ip: ${var.monitoring_srv_ip}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules)))}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
monitoring_enabled: ${var.monitoring_enabled}
monitored_hosts: [${join(", ", formatlist("'%s'", var.host_ips))}]
drbd_monitored_hosts: [${join(", ", formatlist("'%s'", var.drbd_enabled ? var.drbd_ips : []))}]
nw_monitored_hosts: [${join(", ", formatlist("'%s'", var.netweaver_enabled ? var.netweaver_ips : []))}]
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
EOF
    destination = "/tmp/grains"
  }
}

module "monitoring_provision" {
  source               = "../../../generic_modules/salt_provisioner"
  node_count           = var.provisioner == "salt" && var.monitoring_enabled ? 1 : 0
  instance_ids         = null_resource.monitoring_provisioner.*.id
  user                 = "root"
  private_key_location = var.private_key_location
  public_ips           = google_compute_instance.monitoring.*.network_interface.0.access_config.0.nat_ip
  background           = var.background
}
