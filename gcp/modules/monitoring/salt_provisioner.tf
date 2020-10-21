resource "null_resource" "monitoring_provisioner" {
  count = var.common_variables["provisioner"] == "salt" && var.monitoring_enabled ? 1 : 0

  triggers = {
    cluster_instance_id = google_compute_instance.monitoring.0.id
  }

  connection {
    host        = google_compute_instance.monitoring.0.network_interface.0.access_config.0.nat_ip
    type        = "ssh"
    user        = "root"
    private_key = var.common_variables["private_key"]
  }

  provisioner "file" {
    content     = <<EOF
role: monitoring_srv
${var.common_variables["grains_output"]}
name_prefix: ${var.common_variables["deployment_name"]}-monitoring
hostname: ${var.common_variables["deployment_name"]}-monitoring
network_domain: "tf.local"
host_ip: ${var.monitoring_srv_ip}
public_ip: ${google_compute_instance.monitoring[0].network_interface[0].access_config[0].nat_ip}
hana_targets: [${join(", ", formatlist("'%s'", var.hana_targets))}]
drbd_targets: [${join(", ", formatlist("'%s'", var.drbd_targets))}]
netweaver_targets: [${join(", ", formatlist("'%s'", var.netweaver_targets))}]
EOF
    destination = "/tmp/grains"
  }
}

module "monitoring_provision" {
  source               = "../../../generic_modules/salt_provisioner"
  node_count           = var.common_variables["provisioner"] == "salt" && var.monitoring_enabled ? 1 : 0
  instance_ids         = null_resource.monitoring_provisioner.*.id
  user                 = "root"
  private_key          = var.common_variables["private_key"]
  public_ips           = google_compute_instance.monitoring.*.network_interface.0.access_config.0.nat_ip
  background           = var.common_variables["background"]
}
