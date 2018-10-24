# Launch SLES-HAE of SLES4SAP cluster nodes

# Template file for user_data used in resource instances
data "template_file" "init_iscsi" {
  template = "${file("init-iscsi.tpl")}"

  vars {
    iscsidev = "/dev/disk/by-id/google-${google_compute_disk.iscsi_data.name}"
  }
}

data "template_file" "init_nodes" {
  template = "${file("init-nodes.tpl")}"

  vars {
    iscsiip = "${google_compute_instance.iscsisrv.network_interface.0.network_ip}"
  }
}
