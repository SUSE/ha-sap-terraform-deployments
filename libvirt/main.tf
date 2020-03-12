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
  bridge    = var.isolated_network_bridge
  mode      = "none"
  addresses = [var.iprange]
  dhcp {
    enabled = "false"
  }
  dns {
    enabled = true
  }
  autostart = true
}

// Pre deployment local excution
module "local_execution" {
  source  = "../generic_modules/local_exec"
  enabled = var.pre_deployment
}

// ---------------------------------------

module "iscsi_server" {
  source                 = "./modules/iscsi_server"
  iscsi_count            = var.shared_storage_type == "iscsi" ? 1 : 0
  iscsi_image            = var.iscsi_image
  vcpu                   = 2
  memory                 = 4096
  bridge                 = "br0"
  pool                   = var.storage_pool
  network_id             = libvirt_network.isolated_network.id
  iscsi_srv_ip           = var.iscsi_srv_ip
  iscsidev               = "/dev/vdb"
  iscsi_disks            = var.iscsi_disks
  reg_code               = var.reg_code
  reg_email              = var.reg_email
  ha_sap_deployment_repo = var.ha_sap_deployment_repo
  qa_mode                = var.qa_mode
  provisioner            = var.provisioner
  background             = var.background
}

module "sbd_disk" {
  source            = "./modules/shared_disk"
  shared_disk_count = var.shared_storage_type == "shared-disk" ? 1 : 0
  name              = "sbd"
  pool              = var.storage_pool
  shared_disk_size  = 104857600
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
  pool                   = var.storage_pool
  network_id             = libvirt_network.isolated_network.id
  host_ips               = var.host_ips
  hana_inst_folder       = var.hana_inst_folder
  hana_inst_media        = var.hana_inst_media
  hana_disk_size         = "68719476736"
  hana_fstype            = var.hana_fstype
  shared_storage_type    = var.shared_storage_type
  sbd_disk_id            = module.sbd_disk.id
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
}

module "drbd_sbd_disk" {
  source            = "./modules/shared_disk"
  shared_disk_count = var.drbd_enabled == true && var.drbd_shared_storage_type == "shared-disk" ? 1 : 0
  name              = "drbd-sbd"
  pool              = var.storage_pool
  shared_disk_size  = 104857600
}

// drbd01 and drbd02
module "drbd_node" {
  source                 = "./modules/drbd_node"
  name                   = "drbd"
  base_image_id          = libvirt_volume.base_image.id
  drbd_count             = var.drbd_enabled == true ? var.drbd_count : 0
  vcpu                   = 1
  memory                 = 1024
  bridge                 = "br0"
  host_ips               = var.drbd_ips
  drbd_disk_size         = "10737418240" #10GB
  shared_storage_type    = var.drbd_shared_storage_type
  iscsi_srv_ip           = var.iscsi_srv_ip
  reg_code               = var.reg_code
  reg_email              = var.reg_email
  reg_additional_modules = var.reg_additional_modules
  ha_sap_deployment_repo = var.ha_sap_deployment_repo
  devel_mode             = var.devel_mode
  provisioner            = var.provisioner
  background             = var.background
  monitoring_enabled     = var.monitoring_enabled
  network_id             = libvirt_network.isolated_network.id
  pool                   = var.storage_pool
  sbd_disk_id            = module.drbd_sbd_disk.id
}

module "monitoring" {
  source                 = "./modules/monitoring"
  name                   = "monitoring"
  monitoring_enabled     = var.monitoring_enabled
  monitoring_image       = var.monitoring_image
  base_image_id          = libvirt_volume.base_image.id
  vcpu                   = 4
  memory                 = 4095
  bridge                 = "br0"
  pool                   = var.storage_pool
  network_id             = libvirt_network.isolated_network.id
  monitoring_srv_ip      = var.monitoring_srv_ip
  reg_code               = var.reg_code
  reg_email              = var.reg_email
  reg_additional_modules = var.reg_additional_modules
  ha_sap_deployment_repo = var.ha_sap_deployment_repo
  provisioner            = var.provisioner
  background             = var.background
  monitored_hosts        = var.host_ips
  drbd_monitored_hosts   = var.drbd_enabled ? var.drbd_ips : []
  nw_monitored_hosts     = var.netweaver_enabled ? var.nw_ips : []
}

module "nw_shared_disk" {
  source            = "./modules/shared_disk"
  shared_disk_count = var.netweaver_enabled == true ? 1 : 0
  name              = "netweaver-shared"
  pool              = var.storage_pool
  shared_disk_size  = 68719476736
}

module "netweaver_node" {
  source                 = "./modules/netweaver_node"
  name                   = "netweaver"
  base_image_id          = libvirt_volume.base_image.id
  netweaver_count        = var.netweaver_enabled == true ? 4 : 0
  vcpu                   = 4
  memory                 = 8192
  bridge                 = "br0"
  pool                   = var.storage_pool
  network_id             = libvirt_network.isolated_network.id
  host_ips               = var.nw_ips
  virtual_host_ips       = var.nw_virtual_ips
  shared_disk_id         = module.nw_shared_disk.id
  netweaver_inst_media   = var.netweaver_inst_media
  netweaver_nfs_share    = var.netweaver_nfs_share
  reg_code               = var.reg_code
  reg_email              = var.reg_email
  reg_additional_modules = var.reg_additional_modules
  ha_sap_deployment_repo = var.ha_sap_deployment_repo
  provisioner            = var.provisioner
  background             = var.background
  monitoring_enabled     = var.monitoring_enabled
}
