module "hana_node" {
  source = "../host"

  base_configuration = "${var.base_configuration}"
  name = "${var.name}"
  count = "${var.count}"
  additional_repos = "${var.additional_repos}"
  additional_packages = "${var.additional_packages}"
  ssh_key_path = "${var.ssh_key_path}"
  host_ips = "${var.host_ips}"
  grains = <<EOF

role: hana_node
hana_disk_device: vdb
sbd_disk_device: vdc
sap_inst_media: ${var.sap_inst_media}

EOF

  // Provider-specific variables
  memory = "${var.memory}"
  vcpu = "${var.vcpu}"
  running = "${var.running}"
  mac = "${var.mac}"
  hana_disk_size = "${var.hana_disk_size}"

  additional_disk = ["${map(
    "volume_id", "${var.sbd_disk_id}"
  )}"]
}

output "configuration" {
  value {
    id = "${module.hana_node.configuration["id"]}"
    hostname = "${module.hana_node.configuration["hostname"]}"
  }
}
