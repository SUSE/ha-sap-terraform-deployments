provider "libvirt" {
  uri = var.qemu_uri
}

// ---------------------------------------
// this 2 resources are shared among the modules
// baseimage for hana and monitoring modules.
// you can also change it for each modules
// baseimage is "cloned" and used centrally by other domains
resource "libvirt_volume" "base_image" {
  name   = "${terraform.workspace}-baseimage"
  source = var.base_image
  pool   = var.storage_pool
}

// the network used by all modules
resource "libvirt_network" "isolated_network" {
  name      = "${terraform.workspace}-isolated"
  mode      = "none"
  addresses = [var.iprange]
  dhcp {
    enabled = "false"
  }
  autostart = true
}
// ---------------------------------------

module "iscsi_server" {
  source                 = "./modules/iscsi_server"
  iscsi_count            = var.shared_storage_type == "iscsi" ? 1 : 0
  vcpu                   = 2
  memory                 = 4096
  bridge                 = "br0"
  iscsi_image            = var.iscsi_image
  iscsi_srv_ip           = var.iscsi_srv_ip
  iscsidev               = "/dev/vdb"
  reg_code               = var.reg_code
  reg_email              = var.reg_email
  ha_sap_deployment_repo = var.ha_sap_deployment_repo
  provisioner            = var.provisioner
  network_id             = libvirt_network.isolated_network.id
  pool                   = var.storage_pool
  background             = var.background
}

// hana01 and hana02
module "hana_node" {
  source                 = "./modules/hana_node"
  name                   = "hana"
  base_image_id          = libvirt_volume.base_image.id
  hana_count             = 2
  vcpu                   = 4
  memory                 = 32678
  bridge                 = "br0"
  host_ips               = var.host_ips
  hana_inst_folder       = var.hana_inst_folder
  sap_inst_media         = var.sap_inst_media
  hana_disk_size         = "68719476736"
  hana_fstype            = var.hana_fstype
  shared_storage_type    = var.shared_storage_type
  iscsi_srv_ip           = var.iscsi_srv_ip
  reg_code               = var.reg_code
  reg_email              = var.reg_email
  reg_additional_modules = var.reg_additional_modules
  ha_sap_deployment_repo = var.ha_sap_deployment_repo
  qa_mode                = var.qa_mode
  hwcct                  = var.hwcct
  devel_mode             = var.devel_mode
  scenario_type          = var.scenario_type
  provisioner            = var.provisioner
  background             = var.background
  monitoring_enabled     = var.monitoring_enabled
  network_id             = libvirt_network.isolated_network.id
  pool                   = var.storage_pool
  // sbd disk configuration
  sbd_count     = var.shared_storage_type == "shared-disk" ? 1 : 0
  sbd_disk_size = "104857600"
}

module "monitoring" {
  source                 = "./modules/monitoring"
  name                   = "monitoring"
  monitoring_count       = var.monitoring_enabled == true ? 1 : 0
  monitoring_image       = var.monitoring_image
  base_image_id          = libvirt_volume.base_image.id
  vcpu                   = 4
  memory                 = 4095
  bridge                 = "br0"
  monitoring_srv_ip      = var.monitoring_srv_ip
  reg_code               = var.reg_code
  reg_email              = var.reg_email
  reg_additional_modules = var.reg_additional_modules
  ha_sap_deployment_repo = var.ha_sap_deployment_repo
  provisioner            = var.provisioner
  background             = var.background
  monitored_hosts        = var.host_ips
  pool                   = var.storage_pool
  network_id             = libvirt_network.isolated_network.id
}
