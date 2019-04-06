# Launch SLES-HAE of SLES4SAP cluster nodes

# Template file for user_data used in resource instances
data "template_file" "init_server" {
  template = "${file("init-server.tpl")}"

  vars {
    regcode = "${var.reg_code}"
    qa_mode = "${var.qa_mode}"
  }
}
