locals {
  # fileexists doesn't work properly with empty strings ("")
  public_key      = var.public_key != "" ? (fileexists(var.public_key) ? file(var.public_key) : var.public_key) : ""
  private_key     = var.private_key != "" ? (fileexists(var.private_key) ? file(var.private_key) : var.private_key) : ""
  authorized_keys = join(", ", formatlist("\"%s\"",
    concat(
      local.public_key != "" ? [trimspace(local.public_key)] : [],
      [for key in var.authorized_keys: trimspace(fileexists(key) ? file(key) : key)])
    )
  )

  bastion_private_key = var.bastion_private_key != "" ? (fileexists(var.bastion_private_key) ? file(var.bastion_private_key) : var.bastion_private_key) : local.private_key
  bastion_public_key  = var.bastion_public_key != "" ? (fileexists(var.bastion_public_key) ? file(var.bastion_public_key) : var.bastion_public_key) : local.public_key
}

output "configuration" {
  value = {
    provider_type          = var.provider_type
    deployment_name        = var.deployment_name
    reg_code               = var.reg_code
    reg_email              = var.reg_email
    reg_additional_modules = var.reg_additional_modules
    ha_sap_deployment_repo = var.ha_sap_deployment_repo
    additional_packages    = var.additional_packages
    public_key             = local.public_key
    private_key            = local.private_key
    authorized_keys        = var.authorized_keys
    bastion_enabled        = var.bastion_enabled
    bastion_public_key     = local.bastion_public_key
    bastion_private_key    = local.bastion_private_key
    authorized_user        = var.authorized_user
    provisioner            = var.provisioner
    provisioning_log_level = var.provisioning_log_level
    background             = var.background
    monitoring_enabled     = var.monitoring_enabled
    monitoring_srv_ip      = var.monitoring_srv_ip
    qa_mode                = var.qa_mode
    grains_output          = <<EOF
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
EOF
    hana_grains_output     = <<EOF
hana_sid: ${var.hana_sid}
hana_instance_number: ${var.hana_instance_number}
hana_cost_optimized_sid: ${var.hana_cost_optimized_sid}
hana_cost_optimized_instance_number: ${var.hana_cost_optimized_instance_number}
hana_master_password: ${var.hana_master_password}
hana_cost_optimized_master_password: ${var.hana_cost_optimized_master_password}
hana_primary_site: ${var.hana_primary_site}
hana_secondary_site: ${var.hana_secondary_site}
hana_inst_folder: ${var.hana_inst_folder}
hana_fstype: ${var.hana_fstype}
hana_platform_folder: ${var.hana_platform_folder}
hana_sapcar_exe: ${var.hana_sapcar_exe}
hana_archive_file: ${var.hana_archive_file}
hana_extract_dir: ${var.hana_extract_dir}
scenario_type: ${var.scenario_type}
EOF
  }
}
