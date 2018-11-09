resource "google_compute_instance" "clusternodes" {
  description             = "SAP/HA nodes"
  machine_type            = "${var.machine_type_hana_node}"
  metadata_startup_script = "${file("startup.sh")}"
  count                   = "${var.node_count}"
  name                    = "${element(var.node_list, count.index)}"

  can_ip_forward = true

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

  attached_disk {
    source      = "${element(google_compute_disk.backup.*.self_link, count.index)}"
    device_name = "${element(google_compute_disk.backup.*.name, count.index)}"
    mode        = "READ_WRITE"
  }

  metadata {
    sshKeys = "${var.ssh_user}:${file(var.ssh_pub_key_file)}"

    # For a description of these:
    # https://storage.googleapis.com/sapdeploy/dm-templates/sap_hana_ha/template.yaml
    post_deployment_script = ""

    sap_deployment_debug       = "Yes"
    sap_hana_backup_bucket     = ""
    sap_hana_deployment_bucket = "sap_hana2"
    sap_hana_instance_number   = "0"
    sap_hana_sapsys_gid        = "79"
    sap_hana_scaleout_nodes    = "0"
    sap_hana_sid               = "HA0"
    sap_hana_sidadm_password   = "Linux_123"
    sap_hana_sidadm_uid        = "900"
    sap_hana_standby_nodes     = ""
    sap_hana_system_password   = "Linux_123"
    sap_primary_instance       = "node-0"
    sap_primary_zone           = "europe-west1-b"
    sap_secondary_instance     = "node-1"
    sap_secondary_zone         = "europe-west1-c"
    sap_vip                    = "10.0.0.250"
    sap_vip_secondary_range    = ""
  }

  service_account {
    scopes = ["compute-rw", "storage-rw", "logging-write", "monitoring-write", "service-control", "service-management"]
  }
}
