output "configuration" {
  value = {
    reg_code               = var.reg_code
    reg_email              = var.reg_email
    reg_additional_modules = var.reg_additional_modules
    ha_sap_deployment_repo = var.ha_sap_deployment_repo
    additional_packages    = var.additional_packages
    provisioner            = var.provisioner
    background             = var.background
    monitoring_enabled     = var.monitoring_enabled
    monitoring_srv_ip      = var.monitoring_srv_ip
    qa_mode                = var.qa_mode
    grains_output          = <<EOF
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules), ), )}}
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
monitoring_enabled: ${var.monitoring_enabled}
monitoring_srv_ip: ${var.monitoring_srv_ip}
qa_mode: ${var.qa_mode}
EOF
  }
}
