# HANA deployment in OpenStack

locals {
  bastion_enabled            = var.common_variables["bastion_enabled"]
  create_ha_infra            = var.hana_count > 1 && var.common_variables["hana"]["ha_enabled"] ? 1 : 0
  create_data_volumes        = var.hana_count > 1 && var.hana_data_disk_type != "ephemeral" ? true : false
  create_backup_volumes      = var.hana_count > 1 && var.hana_backup_disk_type != "ephemeral" ? true : false
  create_active_active_infra = local.create_ha_infra == 1 && var.common_variables["hana"]["cluster_vip_secondary"] != "" ? 1 : 0
  provisioning_addresses     = openstack_compute_instance_v2.hana.*.access_ip_v4
  hostname                   = var.common_variables["deployment_name_in_hostname"] ? format("%s-%s", var.common_variables["deployment_name"], var.name) : var.name
}

resource "openstack_blockstorage_volume_v3" "data" {
  # only deploy if hana_data_disk_type is not set to ephemeral
  count                = local.create_data_volumes ? var.hana_count : 0
  name                 = "${var.common_variables["deployment_name"]}-hana-data-${count.index}"
  size                 = var.hana_data_disk_size
  availability_zone    = var.region
  enable_online_resize = true
}

resource "openstack_compute_volume_attach_v2" "data_attached" {
  count       = local.create_data_volumes ? var.hana_count : 0
  instance_id = openstack_compute_instance_v2.hana.*.id[count.index]
  volume_id   = openstack_blockstorage_volume_v3.data.*.id[count.index]
}

resource "openstack_blockstorage_volume_v3" "backup" {
  # only deploy if hana_backup_disk_type is not set to ephemeral
  count                = local.create_backup_volumes ? var.hana_count : 0
  name                 = "${var.common_variables["deployment_name"]}-hana-backup-${count.index}"
  size                 = var.hana_backup_disk_size
  availability_zone    = var.region
  enable_online_resize = true
}

resource "openstack_compute_volume_attach_v2" "backup_attached" {
  count       = local.create_backup_volumes ? var.hana_count : 0
  instance_id = openstack_compute_instance_v2.hana.*.id[count.index]
  volume_id   = openstack_blockstorage_volume_v3.backup.*.id[count.index]
}

resource "openstack_networking_port_v2" "hana" {
  count = var.hana_count
  name  = "${var.common_variables["deployment_name"]}-hana-port-${count.index + 1}"

  network_id     = var.network_id
  admin_state_up = "true"
  fixed_ip {
    subnet_id  = var.network_subnet_id
    ip_address = var.host_ips[count.index]
  }
  allowed_address_pairs {
    ip_address = var.hana_cluster_vip
  }
  allowed_address_pairs {
    ip_address = var.hana_cluster_vip_secondary
  }
  security_group_ids = [var.firewall_internal]
}

resource "openstack_compute_instance_v2" "hana" {
  count        = var.hana_count
  name         = "${var.common_variables["deployment_name"]}-${var.name}${format("%02d", count.index + 1)}"
  flavor_name  = var.flavor
  image_id     = var.os_image
  config_drive = true
  user_data    = var.userdata
  key_pair     = "terraform"
  depends_on   = [openstack_networking_port_v2.hana]
  network {
    port = openstack_networking_port_v2.hana[count.index].id
  }
  availability_zone = var.region
}

module "hana_on_destroy" {
  source              = "../../../generic_modules/on_destroy"
  node_count          = var.hana_count
  instance_ids        = openstack_compute_instance_v2.hana.*.id
  user                = var.common_variables["authorized_user"]
  private_key         = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips          = openstack_networking_port_v2.hana.*.fixed_ip.0.ip_address
  dependencies        = var.on_destroy_dependencies
}
