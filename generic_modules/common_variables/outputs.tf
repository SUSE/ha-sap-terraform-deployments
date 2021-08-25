locals {
  # fileexists doesn't work properly with empty strings ("")
  public_key  = var.public_key != "" ? (fileexists(var.public_key) ? file(var.public_key) : var.public_key) : ""
  private_key = var.private_key != "" ? (fileexists(var.private_key) ? file(var.private_key) : var.private_key) : ""
  authorized_keys = join(", ", formatlist("\"%s\"",
    concat(
      local.public_key != "" ? [trimspace(local.public_key)] : [],
    [for key in var.authorized_keys : trimspace(fileexists(key) ? file(key) : key)])
    )
  )

  bastion_private_key = var.bastion_private_key != "" ? (fileexists(var.bastion_private_key) ? file(var.bastion_private_key) : var.bastion_private_key) : local.private_key
  bastion_public_key  = var.bastion_public_key != "" ? (fileexists(var.bastion_public_key) ? file(var.bastion_public_key) : var.bastion_public_key) : local.public_key

  requirements_file = "${path.module}/../../requirements.yml"
  requirements      = fileexists(local.requirements_file) ? yamlencode({pkg_requirements: yamldecode(trimspace(file(local.requirements_file)))}) : yamlencode({pkg_requirements: null})
}

output "configuration" {
  value = {
    provider_type               = var.provider_type
    region                      = var.region
    deployment_name             = var.deployment_name
    deployment_name_in_hostname = var.deployment_name_in_hostname
    reg_code                    = var.reg_code
    reg_email                   = var.reg_email
    reg_additional_modules      = var.reg_additional_modules
    ha_sap_deployment_repo      = var.ha_sap_deployment_repo
    additional_packages         = var.additional_packages
    public_key                  = local.public_key
    private_key                 = local.private_key
    authorized_keys             = var.authorized_keys
    bastion_enabled             = var.bastion_enabled
    bastion_public_key          = local.bastion_public_key
    bastion_private_key         = local.bastion_private_key
    authorized_user             = var.authorized_user
    provisioner                 = var.provisioner
    provisioning_log_level      = var.provisioning_log_level
    provisioning_output_colored = var.provisioning_output_colored
    background                  = var.background
    monitoring_enabled          = var.monitoring_enabled
    monitoring_srv_ip           = var.monitoring_srv_ip
    qa_mode                     = var.qa_mode
    hana = {
      sid                            = var.hana_sid
      instance_number                = var.hana_instance_number
      cost_optimized_sid             = var.hana_cost_optimized_sid
      cost_optimized_instance_number = var.hana_cost_optimized_instance_number
      master_password                = var.hana_master_password
      cost_optimized_master_password = var.hana_cost_optimized_master_password
      primary_site                   = var.hana_primary_site
      secondary_site                 = var.hana_secondary_site
      inst_master                    = var.hana_inst_master
      inst_folder                    = var.hana_inst_folder
      fstype                         = var.hana_fstype
      platform_folder                = var.hana_platform_folder
      sapcar_exe                     = var.hana_sapcar_exe
      archive_file                   = var.hana_archive_file
      extract_dir                    = var.hana_extract_dir
      client_folder                  = var.hana_client_folder
      client_archive_file            = var.hana_client_archive_file
      client_extract_dir             = var.hana_client_extract_dir
      scenario_type                  = var.hana_scenario_type
      cluster_vip_mechanism          = var.hana_cluster_vip_mechanism
      cluster_vip                    = var.hana_cluster_vip
      cluster_vip_secondary          = var.hana_cluster_vip_secondary
      ha_enabled                     = var.hana_ha_enabled
      ignore_min_mem_check           = var.hana_ignore_min_mem_check
      fencing_mechanism              = var.hana_cluster_fencing_mechanism
      sbd_storage_type               = var.hana_sbd_storage_type
      scale_out_shared_storage_type  = var.hana_scale_out_shared_storage_type
    }
    netweaver = {
      ha_enabled           = var.netweaver_ha_enabled
      fencing_mechanism    = var.netweaver_cluster_fencing_mechanism
      sbd_storage_type     = var.netweaver_sbd_storage_type
      sid                  = var.netweaver_sid
      ascs_instance_number = var.netweaver_ascs_instance_number
      ers_instance_number  = var.netweaver_ers_instance_number
      pas_instance_number  = var.netweaver_pas_instance_number
      master_password      = var.netweaver_master_password
      product_id           = var.netweaver_product_id
      inst_folder          = var.netweaver_inst_folder
      extract_dir          = var.netweaver_extract_dir
      swpm_folder          = var.netweaver_swpm_folder
      sapcar_exe           = var.netweaver_sapcar_exe
      swpm_sar             = var.netweaver_swpm_sar
      sapexe_folder        = var.netweaver_sapexe_folder
      additional_dvds      = var.netweaver_additional_dvds
      nfs_share            = var.netweaver_nfs_share
      sapmnt_path          = var.netweaver_sapmnt_path
      hana_ip              = var.netweaver_hana_ip
      hana_sid             = var.netweaver_hana_sid
      hana_instance_number = var.netweaver_hana_instance_number
      hana_master_password = var.netweaver_hana_master_password
      shared_storage_type  = var.netweaver_shared_storage_type
    }
    monitoring = {
      hana_targets          = var.monitoring_hana_targets
      hana_targets_ha       = var.monitoring_hana_targets_ha
      hana_targets_vip      = var.monitoring_hana_targets_vip
      drbd_targets          = var.monitoring_drbd_targets
      drbd_targets_ha       = var.monitoring_drbd_targets_ha
      drbd_targets_vip      = var.monitoring_drbd_targets_vip
      netweaver_targets     = var.monitoring_netweaver_targets
      netweaver_targets_ha  = var.monitoring_netweaver_targets_ha
      netweaver_targets_vip = var.monitoring_netweaver_targets_vip
    }
    grains_output           = <<EOF
provider: ${var.provider_type}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules), ), )}}
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
authorized_keys: [${local.authorized_keys}]
authorized_user: ${var.authorized_user}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
monitoring_enabled: ${var.monitoring_enabled}
monitoring_srv_ip: ${var.monitoring_srv_ip}
qa_mode: ${var.qa_mode}
provisioning_log_level: ${var.provisioning_log_level}
provisioning_output_colored: ${var.provisioning_output_colored}
${local.requirements}
EOF
    hana_grains_output      = <<EOF
hana_sid: ${var.hana_sid}
hana_instance_number: ${var.hana_instance_number}
hana_cost_optimized_sid: ${var.hana_cost_optimized_sid}
hana_cost_optimized_instance_number: ${var.hana_cost_optimized_instance_number}
hana_master_password: ${var.hana_master_password}
hana_cost_optimized_master_password: ${var.hana_cost_optimized_master_password}
hana_primary_site: ${var.hana_primary_site}
hana_secondary_site: ${var.hana_secondary_site}
hana_inst_master: ${var.hana_inst_master}
hana_inst_folder: ${var.hana_inst_folder}
hana_fstype: ${var.hana_fstype}
hana_platform_folder: ${var.hana_platform_folder}
hana_sapcar_exe: ${var.hana_sapcar_exe}
hana_archive_file: ${var.hana_archive_file}
hana_extract_dir: ${var.hana_extract_dir}
hana_client_folder: ${var.hana_client_folder}
hana_client_archive_file: ${var.hana_client_archive_file}
hana_client_extract_dir: ${var.hana_client_extract_dir}
hana_cluster_vip_mechanism: ${var.hana_cluster_vip_mechanism}
hana_cluster_vip: ${var.hana_cluster_vip}
hana_cluster_vip_secondary: ${var.hana_cluster_vip_secondary}
hana_ignore_min_mem_check: ${var.hana_ignore_min_mem_check}
hana_scale_out_shared_storage_type: ${var.hana_scale_out_shared_storage_type}
scenario_type: ${var.hana_scenario_type}
hwcct: ${var.hana_hwcct}
ha_enabled: ${var.hana_ha_enabled}
fencing_mechanism: ${var.hana_cluster_fencing_mechanism}
sbd_storage_type: ${var.hana_sbd_storage_type}
EOF
    netweaver_grains_output = <<EOF
ha_enabled: ${var.netweaver_ha_enabled}
fencing_mechanism: ${var.netweaver_cluster_fencing_mechanism}
sbd_storage_type: ${var.netweaver_sbd_storage_type}
netweaver_sid: ${var.netweaver_sid}
ascs_instance_number: ${var.netweaver_ascs_instance_number}
ers_instance_number: ${var.netweaver_ers_instance_number}
pas_instance_number: ${var.netweaver_pas_instance_number}
netweaver_master_password: ${var.netweaver_master_password}
netweaver_product_id: ${var.netweaver_product_id}
netweaver_inst_folder: ${var.netweaver_inst_folder}
netweaver_extract_dir: ${var.netweaver_extract_dir}
netweaver_swpm_folder: ${var.netweaver_swpm_folder}
netweaver_sapcar_exe: ${var.netweaver_sapcar_exe}
netweaver_swpm_sar: ${var.netweaver_swpm_sar}
netweaver_sapexe_folder: ${var.netweaver_sapexe_folder}
netweaver_additional_dvds: [${join(", ", formatlist("'%s'", var.netweaver_additional_dvds))}]
netweaver_nfs_share: "${var.netweaver_nfs_share}"
netweaver_sapmnt_path: ${var.netweaver_sapmnt_path}
netweaver_shared_storage_type: ${var.netweaver_shared_storage_type}
hana_ip: ${var.netweaver_hana_ip}
hana_sid: ${var.netweaver_hana_sid}
hana_instance_number: ${var.netweaver_hana_instance_number}
hana_master_password: ${var.netweaver_hana_master_password}
EOF
    monitoring_grains_output = <<EOF
hana_targets: [${join(", ", formatlist("'%s'", var.monitoring_hana_targets))}]
hana_targets_ha: [${join(", ", formatlist("'%s'", var.monitoring_hana_targets_ha))}]
hana_targets_vip: [${join(", ", formatlist("'%s'", var.monitoring_hana_targets_vip))}]
drbd_targets: [${join(", ", formatlist("'%s'", var.monitoring_drbd_targets))}]
drbd_targets_ha: [${join(", ", formatlist("'%s'", var.monitoring_drbd_targets_ha))}]
drbd_targets_ha_vip: [${join(", ", formatlist("'%s'", var.monitoring_drbd_targets_vip))}]
netweaver_targets: [${join(", ", formatlist("'%s'", var.monitoring_netweaver_targets))}]
netweaver_targets_ha: [${join(", ", formatlist("'%s'", var.monitoring_netweaver_targets_ha))}]
netweaver_targets_vip: [${join(", ", formatlist("'%s'", var.monitoring_netweaver_targets_vip))}]
EOF
  }
}
