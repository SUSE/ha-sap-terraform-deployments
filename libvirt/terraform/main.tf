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

module "monitoring" {
  source             = "./modules/monitoring"
  base_configuration = "${module.base.configuration}"

  name                   = "monitoring"
  count                  = 1
  vcpu                   = 4
  memory                 = 4095
  // todo: verify this
  host_ips               = "${var.host_ips}"
  
  reg_code               = "${var.reg_code}"
  reg_email              = "${var.reg_email}"
  reg_additional_modules = "${var.reg_additional_modules}"
  additional_repos       = "${var.additional_repos}"
  ha_sap_deployment_repo = "${var.ha_sap_deployment_repo}"
  provisioner            = "${var.provisioner}"
  background             = "${var.background}"
}
