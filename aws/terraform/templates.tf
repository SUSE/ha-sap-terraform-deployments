# Launch SLES-HAE of SLES4SAP cluster nodes

# Template file for user_data used in resource instances
data "template_file" "init_iscsi" {
  template = "${file("init-iscsi.tpl")}"

  vars {
    iscsidev = "/dev/xvdd"
  }
}

data "template_file" "init_nodes" {
  template = "${file("init-nodes.tpl")}"

  vars {
    iscsiip    = "${aws_instance.iscsisrv.private_ip}"
    aws_region = "${var.aws_region}"
    init_type  = "${var.init-type}"
    hana_inst  = "${var.hana_inst_master}"
  }
}
