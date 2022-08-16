# HANA deployment in GCP

locals {
  create_scale_out         = var.hana_count > 1 && var.common_variables["hana"]["scale_out_enabled"] ? 1 : 0
  create_ha_infra          = var.hana_count > 1 && var.common_variables["hana"]["ha_enabled"] ? 1 : 0
  bastion_enabled          = var.common_variables["bastion_enabled"]
  provisioning_addresses   = local.bastion_enabled ? google_compute_instance.clusternodes.*.network_interface.0.network_ip : google_compute_instance.clusternodes.*.network_interface.0.access_config.0.nat_ip
  hostname                 = var.common_variables["deployment_name_in_hostname"] ? format("%s-%s", var.common_variables["deployment_name"], var.name) : var.name
  shared_storage_filestore = var.common_variables["hana"]["scale_out_shared_storage_type"] == "filestore" ? 1 : 0
  compute_zones_hana       = slice(var.compute_zones, 0, 2)
  sites                    = var.common_variables["hana"]["ha_enabled"] ? 2 : 1

  disks_number = length(split(",", var.hana_data_disks_configuration["disks_size"]))
  disks_type   = [for disk_type in split(",", var.hana_data_disks_configuration["disks_type"]) : trimspace(disk_type)]
  disks_size   = [for disk_size in split(",", var.hana_data_disks_configuration["disks_size"]) : tonumber(trimspace(disk_size))]
  disks = flatten([
    for node in range(var.hana_count) : [
      for disk in range(local.disks_number) : {
        node_num    = node
        node        = "${local.hostname}${format("%02d", node + 1)}"
        disk_number = disk
        disk_name   = "${local.hostname}${format("%02d-%s-%02d", node + 1, "disk", disk + 1)}"
        disk_type   = element(local.disks_type, disk)
        disk_size   = element(local.disks_size, disk)
      }
    ]
  ])
}

# HANA disks configuration information: https://cloud.google.com/solutions/sap/docs/sap-hana-planning-guide#storage_configuration

resource "google_compute_disk" "disk" {
  for_each = { for disk in local.disks : "${disk.disk_name}" => disk }

  name = each.value.disk_name
  type = each.value.disk_type
  size = each.value.disk_size
  zone = element(local.compute_zones_hana, each.value.node_num)
}

# Don't remove the routes! Even though the RA gcp-vpc-move-route creates them, if they are not created here, the terraform destroy cannot work as it will find new route names
resource "google_compute_route" "hana-route" {
  name                   = "${var.common_variables["deployment_name"]}-hana-route"
  count                  = local.create_ha_infra == 1 && var.common_variables["hana"]["cluster_vip_mechanism"] == "route" ? 1 : 0
  dest_range             = "${var.common_variables["hana"]["cluster_vip"]}/32"
  network                = var.network_name
  next_hop_instance      = google_compute_instance.clusternodes.0.name
  next_hop_instance_zone = element(var.compute_zones, 0)
  priority               = 1000
}

# Route for Active/Active setup
resource "google_compute_route" "hana-route-secondary" {
  name                   = "${var.common_variables["deployment_name"]}-hana-route-secondary"
  count                  = local.create_ha_infra == 1 && var.common_variables["hana"]["cluster_vip_mechanism"] == "route" && var.common_variables["hana"]["cluster_vip_secondary"] != "" ? 1 : 0
  dest_range             = "${var.common_variables["hana"]["cluster_vip_secondary"]}/32"
  network                = var.network_name
  next_hop_instance      = google_compute_instance.clusternodes.1.name
  next_hop_instance_zone = element(var.compute_zones, 1)
  priority               = 1000
}

# GCP load balancer resource

resource "google_compute_instance_group" "hana-primary-group" {
  name      = "${var.common_variables["deployment_name"]}-hana-primary-group"
  zone      = element(var.compute_zones, 0)
  instances = [google_compute_instance.clusternodes.0.id]
}

resource "google_compute_instance_group" "hana-secondary-group" {
  name      = "${var.common_variables["deployment_name"]}-hana-secondary-group"
  zone      = element(var.compute_zones, 1)
  instances = [google_compute_instance.clusternodes.1.id]
}

module "hana-load-balancer" {
  count                 = local.create_ha_infra == 1 && var.common_variables["hana"]["cluster_vip_mechanism"] == "load-balancer" ? 1 : 0
  source                = "../../modules/load_balancer"
  name                  = "${var.common_variables["deployment_name"]}-hana"
  region                = var.common_variables["region"]
  network_name          = var.network_name
  network_subnet_name   = var.network_subnet_name
  primary_node_group    = google_compute_instance_group.hana-primary-group.id
  secondary_node_group  = google_compute_instance_group.hana-secondary-group.id
  tcp_health_check_port = tonumber("625${var.common_variables["hana"]["instance_number"]}")
  target_tags           = ["hana-group"]
  ip_address            = var.common_variables["hana"]["cluster_vip"]
}

# Load balancer for Active/Active setup
module "hana-secondary-load-balancer" {
  count                 = local.create_ha_infra == 1 && var.common_variables["hana"]["cluster_vip_mechanism"] == "load-balancer" && var.common_variables["hana"]["cluster_vip_secondary"] != "" ? 1 : 0
  source                = "../../modules/load_balancer"
  name                  = "${var.common_variables["deployment_name"]}-hana-secondary"
  region                = var.common_variables["region"]
  network_name          = var.network_name
  network_subnet_name   = var.network_subnet_name
  primary_node_group    = google_compute_instance_group.hana-secondary-group.id
  secondary_node_group  = google_compute_instance_group.hana-primary-group.id
  tcp_health_check_port = tonumber("626${var.common_variables["hana"]["instance_number"]}")
  target_tags           = ["hana-group"]
  ip_address            = var.common_variables["hana"]["cluster_vip_secondary"]
}

# Filestore Storage
resource "google_filestore_instance" "data" {
  # check if local disk for "data" exists
  count = !contains(split("#", lookup(var.hana_data_disks_configuration, "names", "")), "data") ? local.shared_storage_filestore * local.sites : 0

  provider = google-beta
  name     = "${var.common_variables["deployment_name"]}-hana-filestore-${count.index + 1}"
  location = element(local.compute_zones_hana, count.index)
  tier     = var.filestore_tier

  file_shares {
    capacity_gb = var.hana_scale_out_filestore_quota_data
    name        = "data_${count.index + 1}"

    nfs_export_options {
      ip_ranges   = ["0.0.0.0/0"]
      access_mode = "READ_WRITE"
      squash_mode = "NO_ROOT_SQUASH"
    }
  }

  networks {
    network      = var.network_name
    modes        = ["MODE_IPV4"]
    connect_mode = "DIRECT_PEERING"
  }

  timeouts {
    create = "60m"
  }
}

resource "google_filestore_instance" "log" {
  # check if local disk for "log" exists
  count = !contains(split("#", lookup(var.hana_data_disks_configuration, "names", "")), "log") ? local.shared_storage_filestore * local.sites : 0

  provider = google-beta
  name     = "${var.common_variables["deployment_name"]}-hana-filestore-${count.index + 1}"
  location = element(local.compute_zones_hana, count.index)
  tier     = var.filestore_tier

  file_shares {
    capacity_gb = var.hana_scale_out_filestore_quota_log
    name        = "log_${count.index + 1}"

    nfs_export_options {
      ip_ranges   = ["0.0.0.0/0"]
      access_mode = "READ_WRITE"
      squash_mode = "NO_ROOT_SQUASH"
    }
  }

  networks {
    network      = var.network_name
    modes        = ["MODE_IPV4"]
    connect_mode = "DIRECT_PEERING"
  }

  timeouts {
    create = "60m"
  }
}

resource "google_filestore_instance" "backup" {
  # check if local disk for "backup" exists
  count = !contains(split("#", lookup(var.hana_data_disks_configuration, "names", "")), "backup") ? local.shared_storage_filestore * local.sites : 0

  provider = google-beta
  name     = "${var.common_variables["deployment_name"]}-hana-filestore-${count.index + 1}"
  location = element(local.compute_zones_hana, count.index)
  tier     = var.filestore_tier

  file_shares {
    capacity_gb = var.hana_scale_out_filestore_quota_backup
    name        = "backup_${count.index + 1}"

    nfs_export_options {
      ip_ranges   = ["0.0.0.0/0"]
      access_mode = "READ_WRITE"
      squash_mode = "NO_ROOT_SQUASH"
    }
  }

  networks {
    network      = var.network_name
    modes        = ["MODE_IPV4"]
    connect_mode = "DIRECT_PEERING"
  }

  timeouts {
    create = "60m"
  }
}

resource "google_filestore_instance" "shared" {
  # check if local disk for "shared" exists
  count = !contains(split("#", lookup(var.hana_data_disks_configuration, "names", "")), "shared") ? local.shared_storage_filestore * local.sites : 0

  provider = google-beta
  name     = "${var.common_variables["deployment_name"]}-hana-filestore-${count.index + 1}"
  location = element(local.compute_zones_hana, count.index)
  tier     = var.filestore_tier

  file_shares {
    capacity_gb = var.hana_scale_out_filestore_quota_shared
    name        = "shared_${count.index + 1}"

    nfs_export_options {
      ip_ranges   = ["0.0.0.0/0"]
      access_mode = "READ_WRITE"
      squash_mode = "NO_ROOT_SQUASH"
    }
  }

  networks {
    network      = var.network_name
    modes        = ["MODE_IPV4"]
    connect_mode = "DIRECT_PEERING"
  }

  timeouts {
    create = "60m"
  }
}

resource "google_compute_instance" "clusternodes" {
  machine_type = var.machine_type
  name         = "${var.common_variables["deployment_name"]}-${var.name}${format("%02d", count.index + 1)}"
  count        = var.hana_count
  zone         = element(local.compute_zones_hana, count.index)

  can_ip_forward = true

  network_interface {
    subnetwork = var.network_subnet_name
    network_ip = element(var.host_ips, count.index)

    # Set public IP address. Only if the bastion is not used
    dynamic "access_config" {
      for_each = local.bastion_enabled ? [] : [1]
      content {
        nat_ip = ""
      }
    }
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }

  boot_disk {
    initialize_params {
      image = var.os_image
      size  = 60
    }

    auto_delete = true
  }

  dynamic "attached_disk" {
    for_each = { for disk in local.disks : "${disk.disk_name}" => disk if disk.node_num == count.index }
    content {
      source      = google_compute_disk.disk[attached_disk.value.disk_name].id
      device_name = attached_disk.value.disk_name
      mode        = "READ_WRITE"
    }
  }

  metadata = {
    sshKeys = "${var.common_variables["authorized_user"]}:${var.common_variables["public_key"]}"
  }

  service_account {
    scopes = ["compute-rw", "storage-rw", "logging-write", "monitoring-write", "service-control", "service-management"]
  }

  tags = ["hana-group"]
}

module "hana_majority_maker" {
  node_count           = local.create_scale_out
  source               = "../majority_maker_node"
  common_variables     = var.common_variables
  name                 = var.name
  network_domain       = var.network_domain
  bastion_host         = var.bastion_host
  hana_count           = var.hana_count
  majority_maker_ip    = var.majority_maker_ip
  machine_type         = var.machine_type_majority_maker
  compute_zones        = var.compute_zones
  network_name         = var.network_name
  network_subnet_name  = var.network_subnet_name
  os_image             = var.os_image
  gcp_credentials_file = var.gcp_credentials_file
  host_ips             = var.host_ips
  iscsi_srv_ip         = var.iscsi_srv_ip
  cluster_ssh_pub      = var.cluster_ssh_pub
  cluster_ssh_key      = var.cluster_ssh_key
}

module "hana_on_destroy" {
  source              = "../../../generic_modules/on_destroy"
  node_count          = var.hana_count
  instance_ids        = google_compute_instance.clusternodes.*.id
  user                = var.common_variables["authorized_user"]
  private_key         = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips          = local.provisioning_addresses
  dependencies        = var.on_destroy_dependencies
}
