# HANA deployment in OpenStack

locals {
  bastion_enabled        = var.common_variables["bastion_enabled"]
  provisioning_addresses = openstack_compute_instance_v2.drbd.*.access_ip_v4
  create_volumes         = var.drbd_count > 1 && var.drbd_data_disk_type != "ephemeral" ? true : false
  hostname               = var.common_variables["deployment_name_in_hostname"] ? format("%s-%s", var.common_variables["deployment_name"], var.name) : var.name
}

resource "openstack_blockstorage_volume_v3" "data" {
  # only deploy if drbd_data_disk_type is not set to ephemeral
  count                = local.create_volumes ? var.drbd_count : 0
  name                 = "${var.common_variables["deployment_name"]}-drbd-data-${count.index}"
  size                 = var.drbd_data_disk_size
  availability_zone    = var.region
  enable_online_resize = true
}

resource "openstack_compute_volume_attach_v2" "data_attached" {
  # only deploy if drbd_data_disk_type is not set to ephemeral
  count       = local.create_volumes ? var.drbd_count : 0
  instance_id = openstack_compute_instance_v2.drbd.*.id[count.index]
  volume_id   = openstack_blockstorage_volume_v3.data.*.id[count.index]
}

resource "openstack_networking_port_v2" "drbd" {
  count = var.drbd_count
  name  = "${var.common_variables["deployment_name"]}-drbd-port-${count.index + 1}"

  network_id     = var.network_id
  admin_state_up = "true"
  fixed_ip {
    subnet_id  = var.network_subnet_id
    ip_address = var.host_ips[count.index]
  }
  allowed_address_pairs {
    ip_address = var.drbd_cluster_vip
  }
  security_group_ids = [var.firewall_internal]
}

resource "openstack_compute_instance_v2" "drbd" {
  count        = var.drbd_count
  name         = "${var.common_variables["deployment_name"]}-${var.name}${format("%02d", count.index + 1)}"
  flavor_name  = var.flavor
  image_id     = var.os_image
  config_drive = true
  user_data    = var.userdata
  key_pair     = "terraform"
  depends_on   = [openstack_networking_port_v2.drbd]
  network {
    port = openstack_networking_port_v2.drbd[count.index].id
  }
  availability_zone = var.region
}

module "drbd_on_destroy" {
  source              = "../../../generic_modules/on_destroy"
  node_count          = var.drbd_count
  instance_ids        = openstack_compute_instance_v2.drbd.*.id
  user                = var.common_variables["authorized_user"]
  private_key         = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips          = local.provisioning_addresses
  dependencies        = var.on_destroy_dependencies
}
