locals {
  authorized_keys = join(", ", formatlist("\"%s\"",
    concat(
      [trimspace(file(var.public_key_location))],
      [for key in var.authorized_keys: trimspace(file(key))])
    )
  )
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
    public_key_location    = var.public_key_location
    private_key_location   = var.private_key_location
    authorized_keys        = var.authorized_keys
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
  }
}
