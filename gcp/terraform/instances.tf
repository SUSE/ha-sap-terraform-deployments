#resource "google_compute_instance_template" "ha_node_template" {
#  name         = "ha-node-template"
#  machine_type = "${var.machine_type}"
#  description  = "This template is used to create HA node server instances"
#
#  lifecycle {
#    create_before_destroy = true
#  }
#
#  network_interface {
#    subnetwork = "${google_compute_subnetwork.ha_subnet.name}"
#
#    access_config {
#      nat_ip = ""
#    }
#  }
#
#  scheduling {
#    automatic_restart   = true
#    on_host_maintenance = "MIGRATE"
#    preemptible         = false
#  }
#
#  disk {
#    source_image = "${google_compute_image.sles4sap_bootable_image.self_link}"
#    auto_delete  = true
#    boot         = true
#  }
#
#  metadata {
#    sshKeys = "${var.ssh_user}:${file(var.ssh_pub_key_file)}"
#  }
#}

#resource "google_compute_instance_group_manager" "ha_nodes_group" {
#  name               = "ha-nodes-group"
#  description        = "Create identical nodes based on a template"
#  instance_template  = "${google_compute_instance_template.ha_node_template.self_link}"
#  base_instance_name = "ha-nodes-group"
#  update_strategy    = "RESTART"
#  target_size        = "0"
#}

resource "google_compute_instance" "clusternodes" {
  description             = "SAP/HA nodes"
  machine_type            = "${var.machine_type_hana_node}"
  metadata_startup_script = "${data.template_file.init_nodes.rendered}"
  count                   = "${var.node_count}"
  name                    = "${element(var.node_list, count.index)}"

  # lifecycle {
  #   create_before_destroy = true
  # }

  network_interface {
    subnetwork = "${google_compute_subnetwork.ha_subnet.name}"
    network_ip = "10.0.1.${count.index}"

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
  metadata {
    sshKeys = "${var.ssh_user}:${file(var.ssh_pub_key_file)}"
  }
}

resource "google_compute_instance" "iscsisrv" {
  name                    = "iscsisrv"
  description             = "iSCSI server"
  machine_type            = "${var.machine_type_iscsi_server}"
  metadata_startup_script = "${data.template_file.init_iscsi.rendered}"

  lifecycle {
    create_before_destroy = true
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.ha_subnet.name}"
    network_ip = "10.0.0.254"

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
    sshKeys = "${var.ssh_user}:${file(var.ssh_pub_key_file)}"
  }
}
