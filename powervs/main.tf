module "local_execution" {
  source  = "../generic_modules/local_exec"
  enabled = var.pre_deployment
}

locals {
  hana_cluster_vip           = var.hana_cluster_vip != "" ? var.hana_cluster_vip : ""
  hana_cluster_vip_secondary = ""
  drbd_cluster_vip           = ""

  pi_network_ids      = var.bastion_enabled && var.private_pi_network_ids != [] ? var.private_pi_network_ids : var.public_pi_network_ids
  #hana_ips                   = var.hana_ips

  netweaver_count             = 0

  # Check if iscsi server has to be created
  use_sbd       = var.hana_cluster_fencing_mechanism == "sbd" || var.drbd_cluster_fencing_mechanism == "sbd" || var.netweaver_cluster_fencing_mechanism == "sbd"
  iscsi_enabled = var.sbd_storage_type == "iscsi" && ((var.hana_count > 1 && var.hana_ha_enabled) || var.drbd_enabled || (local.netweaver_count > 1 && var.netweaver_ha_enabled)) && local.use_sbd ? true : false

  # Obtain machines os_image value
  hana_os_image       = var.hana_os_image != "" ? var.hana_os_image : var.os_image
  bastion_os_image    = var.bastion_os_image != "" ? var.bastion_os_image : var.os_image
}

module "common_variables" {
  source                              = "../generic_modules/common_variables"
  provider_type                       = "powervs"
  deployment_name                     = local.deployment_name
  reg_code                            = var.reg_code
  reg_email                           = var.reg_email
  reg_additional_modules              = var.reg_additional_modules
  ha_sap_deployment_repo              = var.ha_sap_deployment_repo
  additional_packages                 = var.additional_packages
  public_key                          = var.pi_key_pair_name
  private_key                         = var.private_key
  authorized_keys                     = []
  authorized_user                     = var.admin_user
  bastion_enabled                     = var.bastion_enabled
  bastion_public_key                  = var.bastion_public_key
  bastion_private_key                 = var.bastion_private_key
  provisioner                         = var.provisioner
  provisioning_log_level              = var.provisioning_log_level
  provisioning_output_colored         = var.provisioning_output_colored
  background                          = var.background
  qa_mode                             = var.qa_mode
  hana_hwcct                          = var.hwcct
  hana_sid                            = var.hana_sid
  hana_instance_number                = var.hana_instance_number
  hana_cost_optimized_sid             = var.hana_cost_optimized_sid
  hana_cost_optimized_instance_number = var.hana_cost_optimized_instance_number
  hana_master_password                = var.hana_master_password
  hana_cost_optimized_master_password = var.hana_cost_optimized_master_password == "" ? var.hana_master_password : var.hana_cost_optimized_master_password
  hana_primary_site                   = var.hana_primary_site
  hana_secondary_site                 = var.hana_secondary_site
  hana_inst_master                    = var.hana_inst_master
  hana_inst_folder                    = var.hana_inst_folder
  hana_fstype                         = var.hana_fstype
  hana_platform_folder                = var.hana_platform_folder
  hana_sapcar_exe                     = var.hana_sapcar_exe
  hana_archive_file                   = var.hana_archive_file
  hana_extract_dir                    = var.hana_extract_dir
  hana_client_folder                  = var.hana_client_folder
  hana_client_archive_file            = var.hana_client_archive_file
  hana_client_extract_dir             = var.hana_client_extract_dir
  hana_scenario_type                  = var.scenario_type
  hana_cluster_vip_mechanism          = ""
  hana_cluster_vip                    = var.hana_ha_enabled ? local.hana_cluster_vip : ""
  hana_cluster_vip_secondary          = var.hana_active_active ? local.hana_cluster_vip_secondary : ""
  hana_ha_enabled                     = var.hana_ha_enabled
  hana_cluster_fencing_mechanism      = var.hana_cluster_fencing_mechanism
  hana_sbd_storage_type               = var.sbd_storage_type
  netweaver_sid                       = var.netweaver_sid
  netweaver_ascs_instance_number      = var.netweaver_ascs_instance_number
  netweaver_ers_instance_number       = var.netweaver_ers_instance_number
  netweaver_pas_instance_number       = var.netweaver_pas_instance_number
  netweaver_master_password           = var.netweaver_master_password
  netweaver_product_id                = var.netweaver_product_id
  netweaver_inst_folder               = var.netweaver_inst_folder
  netweaver_extract_dir               = var.netweaver_extract_dir
  netweaver_swpm_folder               = var.netweaver_swpm_folder
  netweaver_sapcar_exe                = var.netweaver_sapcar_exe
  netweaver_swpm_sar                  = var.netweaver_swpm_sar
  netweaver_sapexe_folder             = var.netweaver_sapexe_folder
  netweaver_additional_dvds           = var.netweaver_additional_dvds
  netweaver_nfs_share                 = var.drbd_enabled ? "${local.drbd_cluster_vip}:/${var.netweaver_sid}" : var.netweaver_nfs_share
  netweaver_sapmnt_path               = var.netweaver_sapmnt_path
  #netweaver_hana_ip                   = var.hana_ha_enabled ? local.hana_cluster_vip : element(local.hana_ips, 0)
  netweaver_hana_ip                   = ""
  netweaver_hana_sid                  = var.hana_sid
  netweaver_hana_instance_number      = var.hana_instance_number
  netweaver_hana_master_password      = var.hana_master_password
  netweaver_ha_enabled                = var.netweaver_ha_enabled
  netweaver_cluster_fencing_mechanism = var.netweaver_cluster_fencing_mechanism
  netweaver_sbd_storage_type          = var.sbd_storage_type
}

module "hana_node" {
  source                        = "./modules/hana_node"
  common_variables              = module.common_variables.configuration
  bastion_host                  = module.bastion.public_ip
  bastion_private               = module.bastion.private_ip
  ibmcloud_api_key              = var.ibmcloud_api_key
  region                        = var.region
  zone                          = var.zone
  hana_count                    = var.hana_count
  vcpu                          = var.hana_node_vcpu
  memory                        = var.hana_node_memory
#  host_ips                      = local.hana_ips
#  storage_account               =
#  storage_account_name          = var.storage_account_name
#  storage_account_key           = var.storage_account_key
  hana_instance_number          = var.hana_instance_number
  cluster_ssh_pub               = var.cluster_ssh_pub
  cluster_ssh_key               = var.cluster_ssh_key
  hana_data_disks_configuration = var.hana_data_disks_configuration
  sbd_disk_id                   = module.hana_sbd_disk.id
  sbd_disk_wwn                  = module.hana_sbd_disk.wwn
  os_image                      = local.hana_os_image
  pi_cloud_instance_id          = var.pi_cloud_instance_id
  pi_sys_type                   = var.pi_sys_type
  pi_network_ids                = local.pi_network_ids
  private_pi_network_names      = var.private_pi_network_names
  public_pi_network_names       = var.public_pi_network_names
  pi_key_pair_name              = var.pi_key_pair_name
}
