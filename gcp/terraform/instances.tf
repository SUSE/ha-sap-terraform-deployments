resource "google_compute_instance" "iscsisrv" {
  name                    = "iscsisrv"
  description             = "iSCSI server"
  machine_type            = "${var.machine_type_iscsi_server}"
  metadata_startup_script = "${data.template_file.init_iscsi.rendered}"
  count                   = "${var.use_gcp_stonith == "true" ? 0 : 1}"
  zone                    = "${element(data.google_compute_zones.available.names, count.index)}"

  lifecycle {
    create_before_destroy = true
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.ha_subnet.name}"
    network_ip = "${var.iscsi_ip}"

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
      # XXX: The join() is a workaround for https://github.com/hashicorp/terraform/issues/11566
      image = "${var.use_custom_image == "true" ? "${join("", google_compute_image.sles_bootable_image.*.self_link)}" : "suse-cloud/${var.sles_os_image}"}"
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
}

resource "google_compute_instance" "clusternodes" {
  machine_type            = "${var.machine_type}"
  metadata_startup_script = "${file("startup.sh")}"
  count                   = "2"
  name                    = "${terraform.workspace}-${var.name}-node-${count.index}"
  zone                    = "${element(data.google_compute_zones.available.names, count.index)}"

  can_ip_forward = true

  network_interface {
    subnetwork = "${google_compute_subnetwork.ha_subnet.name}"
    network_ip = "${cidrhost(var.ip_cidr_range, count.index+2)}"

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
      # XXX: The join() is a workaround for https://github.com/hashicorp/terraform/issues/11566
      image = "${var.use_custom_image == "true" ? "${join("", google_compute_image.sles4sap_bootable_image.*.self_link)}" : "suse-sap-cloud/${var.sles4sap_os_image}"}"
    }

    auto_delete = true
  }

  attached_disk {
    source      = "${element(google_compute_disk.node_data.*.self_link, count.index)}"
    device_name = "${element(google_compute_disk.node_data.*.name, count.index)}"
    mode        = "READ_WRITE"
  }

  attached_disk {
    source      = "${element(google_compute_disk.backup.*.self_link, count.index)}"
    device_name = "${element(google_compute_disk.backup.*.name, count.index)}"
    mode        = "READ_WRITE"
  }

  metadata {
    sshKeys = "root:${file(var.public_key_location)}"

    # For a description of these:
    # https://storage.googleapis.com/sapdeploy/dm-templates/sap_hana_ha/template.yaml

    post_deployment_script     = "${var.post_deployment_script}"
    sap_deployment_debug       = "${var.sap_deployment_debug}"
    sap_hana_backup_bucket     = ""
    sap_hana_deployment_bucket = "${var.sap_hana_deployment_bucket}"
    sap_hana_instance_number   = "${var.sap_hana_instance_number}"
    sap_hana_sapsys_gid        = "${var.sap_hana_sapsys_gid}"
    sap_hana_scaleout_nodes    = "0"
    sap_hana_sid               = "${var.sap_hana_sid}"
    sap_hana_sidadm_password   = "${var.sap_hana_sidadm_password}"
    sap_hana_sidadm_uid        = "${var.sap_hana_sidadm_uid}"
    sap_hana_standby_nodes     = ""
    sap_hana_system_password   = "${var.sap_hana_system_password}"
    sap_primary_instance       = "${terraform.workspace}-${var.name}-node-0"
    sap_primary_zone           = "${data.google_compute_zones.available.names[0]}"
    sap_secondary_instance     = "${terraform.workspace}-${var.name}-node-1"
    sap_secondary_zone         = "${data.google_compute_zones.available.names[1]}"
    sap_vip                    = "${var.sap_vip}"
    sap_vip_secondary_range    = ""
    suse_regcode               = "${var.suse_regcode}"
    init_type                  = "${var.init_type}"
    iscsi_ip                   = "${var.iscsi_ip}"
    use_gcp_stonith            = "${var.use_gcp_stonith}"
  }

  service_account {
    scopes = ["compute-rw", "storage-rw", "logging-write", "monitoring-write", "service-control", "service-management"]
  }

  provisioner "file" {
    source      = "./provision/"
    destination = "/root/provision/"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file(var.private_key_location)}"
    }
  }
}
