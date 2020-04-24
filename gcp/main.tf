module "local_execution" {
  source  = "../generic_modules/local_exec"
  enabled = var.pre_deployment
}

module "drbd_node" {
  source                 = "./modules/drbd_node"
  drbd_count             = var.drbd_enabled == true ? 2 : 0
  machine_type           = var.drbd_machine_type
  compute_zones          = data.google_compute_zones.available.names
  network_name           = google_compute_network.ha_network.name
  network_subnet_name    = google_compute_subnetwork.ha_subnet.name
  drbd_image             = var.drbd_image
  drbd_data_disk_size    = var.drbd_data_disk_size
  drbd_data_disk_type    = var.drbd_data_disk_type
  drbd_cluster_vip       = var.drbd_cluster_vip
  gcp_credentials_file   = var.gcp_credentials_file
  network_domain         = "tf.local"
  host_ips               = var.drbd_ips
  iscsi_srv_ip           = module.iscsi_server.iscsisrv_ip
  public_key_location    = var.public_key_location
  private_key_location   = var.private_key_location
  cluster_ssh_pub        = var.cluster_ssh_pub
  cluster_ssh_key        = var.cluster_ssh_key
  reg_code               = var.reg_code
  reg_email              = var.reg_email
  reg_additional_modules = var.reg_additional_modules
  ha_sap_deployment_repo = var.ha_sap_deployment_repo
  monitoring_enabled     = var.monitoring_enabled
  devel_mode             = var.devel_mode
  provisioner            = var.provisioner
  background             = var.background
  on_destroy_dependencies = [
    google_compute_firewall.ha_firewall_allow_tcp
  ]
}

module "netweaver_node" {
  source                     = "./modules/netweaver_node"
  netweaver_count            = var.netweaver_enabled == true ? 4 : 0
  machine_type               = var.netweaver_machine_type
  compute_zones              = data.google_compute_zones.available.names
  network_name               = google_compute_network.ha_network.name
  network_subnet_name        = google_compute_subnetwork.ha_subnet.name
  netweaver_image            = var.netweaver_image
  gcp_credentials_file       = var.gcp_credentials_file
  network_domain             = "tf.local"
  host_ips                   = var.netweaver_ips
  iscsi_srv_ip               = module.iscsi_server.iscsisrv_ip
  public_key_location        = var.public_key_location
  private_key_location       = var.private_key_location
  cluster_ssh_pub            = var.cluster_ssh_pub
  cluster_ssh_key            = var.cluster_ssh_key
  netweaver_product_id       = var.netweaver_product_id
  netweaver_software_bucket  = var.netweaver_software_bucket
  netweaver_swpm_folder      = var.netweaver_swpm_folder
  netweaver_sapcar_exe       = var.netweaver_sapcar_exe
  netweaver_swpm_sar         = var.netweaver_swpm_sar
  netweaver_swpm_extract_dir = var.netweaver_swpm_extract_dir
  netweaver_sapexe_folder    = var.netweaver_sapexe_folder
  netweaver_additional_dvds  = var.netweaver_additional_dvds
  netweaver_nfs_share        = "${var.drbd_cluster_vip}:/HA1"
  hana_cluster_vip           = var.hana_cluster_vip
  virtual_host_ips           = var.netweaver_virtual_ips
  reg_code                   = var.reg_code
  reg_email                  = var.reg_email
  reg_additional_modules     = var.reg_additional_modules
  ha_sap_deployment_repo     = var.ha_sap_deployment_repo
  devel_mode                 = var.devel_mode
  provisioner                = var.provisioner
  background                 = var.background
  monitoring_enabled         = var.monitoring_enabled
  on_destroy_dependencies = [
    google_compute_firewall.ha_firewall_allow_tcp
  ]
}

module "hana_node" {
  source                     = "./modules/hana_node"
  hana_count                 = var.hana_count
  machine_type               = var.machine_type
  compute_zones              = data.google_compute_zones.available.names
  network_name               = google_compute_network.ha_network.name
  network_subnet_name        = google_compute_subnetwork.ha_subnet.name
  init_type                  = var.init_type
  sles4sap_boot_image        = var.sles4sap_boot_image
  gcp_credentials_file       = var.gcp_credentials_file
  host_ips                   = var.host_ips
  iscsi_srv_ip               = module.iscsi_server.iscsisrv_ip
  sap_hana_deployment_bucket = var.sap_hana_deployment_bucket
  hana_inst_folder           = var.hana_inst_folder
  hana_platform_folder       = var.hana_platform_folder
  hana_sapcar_exe            = var.hana_sapcar_exe
  hdbserver_sar              = var.hdbserver_sar
  hana_extract_dir           = var.hana_extract_dir
  hana_data_disk_type        = var.hana_data_disk_type
  hana_data_disk_size        = var.hana_data_disk_size
  hana_backup_disk_type      = var.hana_backup_disk_type
  hana_backup_disk_size      = var.hana_backup_disk_size
  hana_disk_device           = var.hana_disk_device
  hana_backup_device         = var.hana_backup_device
  hana_inst_disk_device      = var.hana_inst_disk_device
  hana_fstype                = var.hana_fstype
  hana_cluster_vip           = var.hana_cluster_vip
  scenario_type              = var.scenario_type
  public_key_location        = var.public_key_location
  private_key_location       = var.private_key_location
  cluster_ssh_pub            = var.cluster_ssh_pub
  cluster_ssh_key            = var.cluster_ssh_key
  reg_code                   = var.reg_code
  reg_email                  = var.reg_email
  reg_additional_modules     = var.reg_additional_modules
  ha_sap_deployment_repo     = var.ha_sap_deployment_repo
  additional_packages        = var.additional_packages
  devel_mode                 = var.devel_mode
  hwcct                      = var.hwcct
  qa_mode                    = var.qa_mode
  provisioner                = var.provisioner
  background                 = var.background
  monitoring_enabled         = var.monitoring_enabled
  on_destroy_dependencies = [
    google_compute_firewall.ha_firewall_allow_tcp
  ]
}

module "monitoring" {
  source                 = "./modules/monitoring"
  compute_zones          = data.google_compute_zones.available.names
  network_subnet_name    = google_compute_subnetwork.ha_subnet.name
  sles4sap_boot_image    = var.sles4sap_boot_image
  host_ips               = var.host_ips
  public_key_location    = var.public_key_location
  private_key_location   = var.private_key_location
  reg_code               = var.reg_code
  reg_email              = var.reg_email
  reg_additional_modules = var.reg_additional_modules
  ha_sap_deployment_repo = var.ha_sap_deployment_repo
  additional_packages    = var.additional_packages
  monitoring_srv_ip      = var.monitoring_srv_ip
  monitoring_enabled     = var.monitoring_enabled
  provisioner            = var.provisioner
  background             = var.background
  on_destroy_dependencies = [
    google_compute_firewall.ha_firewall_allow_tcp
  ]
}

module "iscsi_server" {
  source                    = "./modules/iscsi_server"
  machine_type_iscsi_server = var.machine_type_iscsi_server
  compute_zones             = data.google_compute_zones.available.names
  network_subnet_name       = google_compute_subnetwork.ha_subnet.name
  iscsi_server_boot_image   = var.iscsi_server_boot_image
  iscsi_srv_ip              = var.iscsi_srv_ip
  iscsidev                  = var.iscsidev
  iscsi_disks               = var.iscsi_disks
  public_key_location       = var.public_key_location
  private_key_location      = var.private_key_location
  reg_code                  = var.reg_code
  reg_email                 = var.reg_email
  reg_additional_modules    = var.reg_additional_modules
  ha_sap_deployment_repo    = var.ha_sap_deployment_repo
  additional_packages       = var.additional_packages
  qa_mode                   = var.qa_mode
  provisioner               = var.provisioner
  background                = var.background
  on_destroy_dependencies = [
    google_compute_firewall.ha_firewall_allow_tcp
  ]
}
