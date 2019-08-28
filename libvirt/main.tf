provider "libvirt" {
  uri = var.qemu_uri
}

module "base" {
  source  = "./modules/base"
  network_name = ""
  bridge       = "br0"
  timezone     = "Europe/Berlin"
}

// this image will be "cloned" and used by other domains 
resource "libvirt_volume" "base_image" {
  name   = "${terraform.workspace}-baseimage"
  source = var.base_image
  // TODO: check this better
  pool   = "terraform"
}


resource "libvirt_network" "isolated_network" {
  name      = "${terraform.workspace}-isolated"
  mode      = "none"
  addresses = [var.iprange]

  dhcp {
    enabled = "false"
  }

  autostart = true
}

module "iscsi_server" {
  source                 = "./modules/iscsi_server"
  iscsi_count            = var.shared_storage_type == "iscsi" ? 1 : 0
  vcpu                   = 2
  memory                 = 4096
  base_configuration     = module.base.configuration
  iscsi_image            = var.iscsi_image
  iscsi_srv_ip           = var.iscsi_srv_ip
  iscsidev               = "/dev/vdb"
  reg_code               = var.reg_code
  reg_email              = var.reg_email
  ha_sap_deployment_repo = var.ha_sap_deployment_repo
  provisioner            = var.provisioner
  network_id             = libvirt_network.isolated_network.id
  background             = var.background
}

module "hana_node" {
  source             = "./modules/hana_node"
  base_configuration = module.base.configuration

  // hana01 and hana02

  name                   = "hana"
  hana_count             = 2
  vcpu                   = 4
  memory                 = 32678
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
  additional_repos       = var.additional_repos
  ha_sap_deployment_repo = var.ha_sap_deployment_repo
  scenario_type          = var.scenario_type
  provisioner            = var.provisioner
  background             = var.background
  monitoring_enabled     = var.monitoring_enabled
  network_id             = libvirt_network.isolated_network.id

  // sbd disk configuration
  sbd_count     = var.shared_storage_type == "shared-disk" ? 1 : 0
  sbd_disk_size = "104857600"
}

module "monitoring" {
  source             = "./modules/monitoring"
  base_configuration = module.base.configuration

  name                   = "monitoring"
  monitoring_count       = 1
  vcpu                   = 4
  memory                 = 4095
  monitoring_srv_ip      = var.monitoring_srv_ip
  reg_code               = var.reg_code
  reg_email              = var.reg_email
  reg_additional_modules = var.reg_additional_modules
  additional_repos       = var.additional_repos
  ha_sap_deployment_repo = var.ha_sap_deployment_repo
  provisioner            = var.provisioner
  background             = var.background
  monitored_services     = var.monitored_services
  
  network_id             = libvirt_network.isolated_network.id
}
