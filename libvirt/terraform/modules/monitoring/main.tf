module "monitoring" {
  source = "../host"

  base_configuration     = "${var.base_configuration}"
  name                   = "${var.name}"
  count                  = "${var.count}"
  reg_code               = "${var.reg_code}"
  reg_email              = "${var.reg_email}"
  reg_additional_modules = "${var.reg_additional_modules}"
  additional_repos       = "${var.additional_repos}"
  additional_packages    = "${var.additional_packages}"
  public_key_location    = "${var.public_key_location}"
  host_ips               = "${list(var.monitoring_srv_ip)}"
  provisioner            = "${var.provisioner}"
  background             = "${var.background}"
  install_salt_minion    = "${var.install_salt_minion}"

  grains = <<EOF
role: monitoring
provider: libvirt
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
monitored_services: [${join(", ", formatlist("'%s'", var.monitored_services))}]
EOF

  // Provider-specific variables
  memory = 4096
  vcpu   = "${var.vcpu}"
  mac    = "${var.mac}"
}

output "configuration" {
  value = "${module.monitoring.configuration}"
}

output "addresses" {
  value {
    addresses = "${module.monitoring.addresses}"
  }
}
