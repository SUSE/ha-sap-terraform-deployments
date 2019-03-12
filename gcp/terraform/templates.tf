# Template file for user_data used in resource instances
data "template_file" "init_iscsi" {
  template = "${file("init-iscsi.tpl")}"

  vars {
    iscsidev = "/dev/disk/by-id/google-${google_compute_disk.iscsi_data.name}"
    iscsi_ip = "${var.iscsi_ip}"
  }
}
