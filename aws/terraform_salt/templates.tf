# Launch SLES-HAE of SLES4SAP cluster nodes

# Template file for user_data used in resource instances
data "template_file" "init_server" {
  template = "${file("init-server.tpl")}"

  vars {
    QA_REG_CODE = "${var.qa_reg_code}"
    REGCODE = "${var.reg_code}"
    QA_MODE = "${var.qa_mode}"
  }
}
