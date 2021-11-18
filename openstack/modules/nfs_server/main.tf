locals {
  bastion_enabled        = var.common_variables["bastion_enabled"]
  provisioning_addresses = openstack_compute_instance_v2.nfssrv.*.access_ip_v4
  hostname               = var.common_variables["deployment_name_in_hostname"] ? format("%s-%s", var.common_variables["deployment_name"], var.name) : var.name
  create_data_volume     = var.nfs_count == 1 && length(var.nfs_data_volume_names) == 0 ? true : false
  nfs_data_volume_count  = length(var.nfs_data_volume_names) == 0 ? 1 : length(var.nfs_data_volume_names)
}

resource "openstack_networking_port_v2" "nfssrv" {
  count = var.nfs_count
  name  = "${var.common_variables["deployment_name"]}-nfssrv-port-${count.index + 1}"

  network_id     = var.network_id
  admin_state_up = "true"
  fixed_ip {
    subnet_id  = var.network_subnet_id
    ip_address = var.host_ips[count.index]
  }
  security_group_ids = [var.firewall_internal]
}

data "openstack_blockstorage_volume_v3" "existing_nfssrv_volumes" {
  for_each = toset(var.nfs_data_volume_names)
  name     = each.key
}

resource "openstack_blockstorage_volume_v3" "nfssrv_volume" {
  count                = local.create_data_volume ? 1 : 0
  name                 = format("%s-nfs-disk-%s", var.common_variables["deployment_name"], count.index + 1)
  size                 = var.nfs_volume_size
  availability_zone    = var.region
  enable_online_resize = true
}

resource "openstack_compute_instance_v2" "nfssrv" {
  count        = var.nfs_count
  name         = "${var.common_variables["deployment_name"]}-${var.name}${format("%02d", count.index + 1)}"
  flavor_name  = var.flavor
  image_id     = var.os_image
  config_drive = true
  user_data    = var.userdata
  key_pair     = "terraform"
  depends_on   = [openstack_networking_port_v2.nfssrv]
  network {
    port = openstack_networking_port_v2.nfssrv.0.id
  }
  availability_zone = var.region
}

resource "openstack_compute_volume_attach_v2" "existing_nfssrv_volumes_attached" {
  for_each    = data.openstack_blockstorage_volume_v3.existing_nfssrv_volumes
  instance_id = openstack_compute_instance_v2.nfssrv.0.id
  volume_id   = each.value.id
}

resource "openstack_compute_volume_attach_v2" "nfssrv_volume_attached" {
  count       = local.create_data_volume ? 1 : 0
  instance_id = openstack_compute_instance_v2.nfssrv.*.id[count.index]
  volume_id   = openstack_blockstorage_volume_v3.nfssrv_volume.*.id[count.index]
}

module "nfs_on_destroy" {
  source              = "../../../generic_modules/on_destroy"
  node_count          = var.nfs_count
  instance_ids        = openstack_compute_instance_v2.nfssrv.*.id
  user                = var.common_variables["authorized_user"]
  private_key         = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips          = local.provisioning_addresses
  dependencies        = var.on_destroy_dependencies
}
