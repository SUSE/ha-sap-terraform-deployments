module "hana_node" {
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

  grains = <<EOF

provider: libvirt
role: hana_node
hana_disk_device: /dev/vdb
sbd_disk_device: /dev/vdc
sap_inst_media: ${var.sap_inst_media}
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}

EOF

  // Provider-specific variables
  memory         = "${var.memory}"
  vcpu           = "${var.vcpu}"
  running        = "${var.running}"
  mac            = "${var.mac}"
  hana_disk_size = "${var.hana_disk_size}"

  additional_disk = ["${map(
    "volume_id", "${var.sbd_disk_id}"
  )}"]
}

output "configuration" {
  value {
    id       = "${module.hana_node.configuration["id"]}"
    hostname = "${module.hana_node.configuration["hostname"]}"
  }
}

output "addresses" {
  value {
    addresses = "${module.hana_node.addresses}"
  }
}
