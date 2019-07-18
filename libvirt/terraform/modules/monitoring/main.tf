module "grafana" {
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
  host_ips               = "${var.host_ips}"
  provisioner            = "${var.provisioner}"
  background             = "${var.background}"

  grains = <<EOF
role: monitoring
provider: libvirt
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
EOF

  // Provider-specific variables
  memory  = 4096
  vcpu    = "${var.vcpu}"
  running = "${var.running}"
  mac     = "${var.mac}"
}

output "configuration" {
  value = "${module.grafana.configuration}"
}
