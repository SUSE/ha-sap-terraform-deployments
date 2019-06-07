provider "libvirt" {
  uri = "${var.qemu_uri}"
}

module "base" {
  source  = "./modules/base"
  image   = "${var.base_image}"
  iprange = "${var.iprange}"

  // pool = "default"
  pool = "terraform"

  // network_name = "default"
  network_name = ""
  bridge       = "br0"
  timezone     = "Europe/Berlin"
}

module "sbd_disk" {
  source             = "./modules/sbd"
  count              = "${var.shared_storage_type == "shared-disk" ? 1 : 0}"
  base_configuration = "${module.base.configuration}"
  sbd_disk_size      = "104857600"
}

module "iscsi_server" {
  source                 = "./modules/iscsi_server"
  count                  = "${var.shared_storage_type == "iscsi" ? 1 : 0}"
  vcpu                   = 2
  memory                 = 4096
  base_configuration     = "${module.base.configuration}"
  iscsi_image            = "${var.iscsi_image}"
  iscsi_srv_ip           = "${var.iscsi_srv_ip}"
  iscsidev               = "/dev/vdb"
  reg_code               = "${var.reg_code}"
  reg_email              = "${var.reg_email}"
  ha_sap_deployment_repo = "${var.ha_sap_deployment_repo}"
  provisioner            = "${var.provisioner}"
  background             = "${var.background}"
}

module "hana_node" {
  source             = "./modules/hana_node"
  base_configuration = "${module.base.configuration}"

  // hana01 and hana02

  name                   = "hana"
  count                  = 2
  vcpu                   = 4
  memory                 = 32678
  hana_inst_folder       = "${var.hana_inst_folder}"
  sap_inst_media         = "${var.sap_inst_media}"
  hana_disk_size         = "68719476736"
  hana_fstype            = "${var.hana_fstype}"
  host_ips               = "${var.host_ips}"
  shared_storage_type    = "${var.shared_storage_type}"
  sbd_disk_id            = "${module.sbd_disk.id}"
  iscsi_srv_ip           = "${var.iscsi_srv_ip}"
  reg_code               = "${var.reg_code}"
  reg_email              = "${var.reg_email}"
  reg_additional_modules = "${var.reg_additional_modules}"
  additional_repos       = "${var.additional_repos}"
  ha_sap_deployment_repo = "${var.ha_sap_deployment_repo}"
  scenario_type          = "${var.scenario_type}"
  provisioner            = "${var.provisioner}"
  background             = "${var.background}"
}
