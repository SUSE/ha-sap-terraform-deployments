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

module "shared_disk" {
  source             = "./modules/sbd"
  base_configuration = "${module.base.configuration}"
  sbd_disk_size      = "68719476736"
}

module "netweaver_node" {
  source             = "./modules/netweaver_node"
  base_configuration = "${module.base.configuration}"

  name                   = "netweaver"
  count                  = 2
  vcpu                   = 4
  memory                 = 32678
  host_ips               = "${var.host_ips}"
  shared_disk_id         = "${module.shared_disk.id}"
  reg_code               = "${var.reg_code}"
  reg_email              = "${var.reg_email}"
  reg_additional_modules = "${var.reg_additional_modules}"
  additional_repos       = "${var.additional_repos}"
  ha_sap_deployment_repo = "${var.ha_sap_deployment_repo}"
  provisioner            = "${var.provisioner}"
  background             = "${var.background}"
  monitored_services     = "${var.monitored_services}"
}
