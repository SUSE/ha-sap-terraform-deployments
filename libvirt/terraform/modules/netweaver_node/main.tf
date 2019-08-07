module "netweaver_node" {
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

provider: libvirt
role: netweaver_node
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
monitored_services: [${join(", ", formatlist("'%s'", var.monitored_services))}]

EOF

  // Provider-specific variables
  memory         = "${var.memory}"
  vcpu           = "${var.vcpu}"
  mac            = "${var.mac}"
  hana_disk_size = "68719476736"

  additional_disk = "${list(
      map("volume_id", "${var.shared_disk_id}")
  )}"
}

output "configuration" {
  value {
    id       = "${module.netweaver_node.configuration["id"]}"
    hostname = "${module.netweaver_node.configuration["hostname"]}"
  }
}

output "addresses" {
  value {
    addresses = "${module.netweaver_node.addresses}"
  }
}
