resource "google_compute_instance" "iscsisrv" {
  name                    = "${terraform.workspace}-iscsisrv"
  description             = "iSCSI server"
  machine_type            = "${var.machine_type_iscsi_server}"
  metadata_startup_script = "${data.template_file.init_server.rendered}"
  zone                    = "${element(data.google_compute_zones.available.names, count.index)}"

  lifecycle {
    create_before_destroy = true
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.ha_subnet.name}"
    address = "${var.iscsi_ip}"

    access_config {
      nat_ip = ""
    }
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }

  boot_disk {
    initialize_params {
      image = "${google_compute_image.sles_bootable_image.self_link}"
    }

    auto_delete = true
  }

  attached_disk {
    source      = "${google_compute_disk.iscsi_data.self_link}"
    device_name = "${google_compute_disk.iscsi_data.name}"
    mode        = "READ_WRITE"
  }

  metadata {
    sshKeys = "root:${file(var.public_key_location)}"
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${file(var.private_key_location)}"
  }

  provisioner "file" {
    source      = "../../salt"
    destination = "/root/"
  }

  provisioner "file" {
    content = <<EOF
provider: "gcp"
iscsi_srv_ip: ${var.iscsi_ip}
iscsidev: ${var.iscsidev}
role: "iscsi_srv"
qa_mode: ${var.qa_mode}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules)))}}
additional_repos: {${join(", ", formatlist("'%s': '%s'", keys(var.additional_repos), values(var.additional_repos)))}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}

partitions:
  1:
    start: 0
    end: 1024
  2:
    start: 1025
    end: 2048
  3:
    start: 2049
    end: 3072
  4:
    start: 3073
    end: 4096
  5:
    start: 4097
    end: 5120
 EOF

    destination = "/tmp/grains"
  }
}

resource "google_compute_instance" "clusternodes" {
  machine_type            = "${var.machine_type}"
  name                    = "${terraform.workspace}-node-${count.index}"
  metadata_startup_script = "${data.template_file.init_server.rendered}"
  count                   = "${var.ninstances}"
  zone                    = "${element(data.google_compute_zones.available.names, count.index)}"

  can_ip_forward = true

  network_interface {
    subnetwork = "${google_compute_subnetwork.ha_subnet.name}"
    address = "${element(var.host_ips, count.index)}"

    access_config {
      nat_ip = ""
    }
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }

  boot_disk {
    initialize_params {
      image = "${google_compute_image.sles4sap_bootable_image.self_link}"
    }

    auto_delete = true
  }

  attached_disk {
    source      = "${element(google_compute_disk.node_data.*.self_link, count.index)}"
    device_name = "${element(google_compute_disk.node_data.*.name, count.index)}"
    mode        = "READ_WRITE"
  }

  attached_disk {
    source      = "${element(google_compute_disk.node_data2.*.self_link, count.index)}"
    device_name = "${element(google_compute_disk.node_data2.*.name, count.index)}"
    mode        = "READ_WRITE"
  }

  metadata {
    sshKeys = "root:${file(var.public_key_location)}"
  }

  service_account {
    scopes = ["compute-rw", "storage-rw", "logging-write", "monitoring-write", "service-control", "service-management"]
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${file(var.private_key_location)}"
  }

  provisioner "file" {
    source      = "../../salt"
    destination = "/root/"
  }

  provisioner "file" {
    source      = "${var.gcp_credentials_file}"
    destination = "/root/google_credentials.json"
  }

  provisioner "file" {
    content = <<EOF
provider: "gcp"
role: "hana_node"
name_prefix: ${var.name}
host_ips: [${join(", ", formatlist("'%s'", var.host_ips))}]
hostname: ${var.name}${var.ninstances > 1 ? "0${count.index  + 1}" : ""}
domain: "tf.local"
sbd_disk_device: /dev/sdd
hana_inst_folder: ${var.hana_inst_folder}
hana_disk_device: ${var.hana_disk_device}
hana_inst_disk_device: ${var.hana_inst_disk_device}
hana_fstype: ${var.hana_fstype}
gcp_credentials_file: ${var.gcp_credentials_file}
sap_hana_deployment_bucket: ${var.sap_hana_deployment_bucket}
iscsi_srv_ip: ${var.iscsi_ip}
init_type: ${var.init_type}
cluster_ssh_pub:  ${var.cluster_ssh_pub}
cluster_ssh_key: ${var.cluster_ssh_key}
qa_mode: ${var.qa_mode}
reg_code: ${var.reg_code}
reg_email: ${var.reg_email}
reg_additional_modules: {${join(", ", formatlist("'%s': '%s'", keys(var.reg_additional_modules), values(var.reg_additional_modules)))}}
additional_repos: {${join(", ", formatlist("'%s': '%s'", keys(var.additional_repos), values(var.additional_repos)))}}
additional_packages: [${join(", ", formatlist("'%s'", var.additional_packages))}]
ha_sap_deployment_repo: ${var.ha_sap_deployment_repo}
EOF

    destination = "/tmp/grains"
  }
}
