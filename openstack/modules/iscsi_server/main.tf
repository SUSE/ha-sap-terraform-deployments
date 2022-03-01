locals {
  bastion_enabled        = var.common_variables["bastion_enabled"]
  provisioning_addresses = openstack_compute_instance_v2.iscsisrv.*.access_ip_v4
  hostname               = var.common_variables["deployment_name_in_hostname"] ? format("%s-%s", var.common_variables["deployment_name"], var.name) : var.name
}


resource "openstack_networking_port_v2" "iscsisrv" {
  count = var.iscsi_count
  name  = "${var.common_variables["deployment_name"]}-iscsisrv-port-${count.index + 1}"

  network_id     = var.network_id
  admin_state_up = "true"
  fixed_ip {
    subnet_id  = var.network_subnet_id
    ip_address = var.host_ips[count.index]
  }
  security_group_ids = [var.firewall_internal]
}

resource "openstack_blockstorage_volume_v3" "iscsisrv_sbd" {
  count                = var.iscsi_count
  name                 = format("%s-iscsi-disk-%s", var.common_variables["deployment_name"], count.index + 1)
  size                 = 1
  availability_zone    = var.region
  enable_online_resize = true
}

resource "openstack_compute_instance_v2" "iscsisrv" {
  count        = var.iscsi_count
  name         = "${var.common_variables["deployment_name"]}-${var.name}${format("%02d", count.index + 1)}"
  flavor_name  = var.flavor
  image_id     = var.os_image
  config_drive = true
  user_data    = var.userdata
  key_pair     = "terraform"
  depends_on   = [openstack_networking_port_v2.iscsisrv]
  network {
    port = openstack_networking_port_v2.iscsisrv.0.id
  }
  availability_zone = var.region
}

resource "openstack_compute_volume_attach_v2" "iscsisrv_sbd_attached" {
  count       = var.iscsi_count
  instance_id = openstack_compute_instance_v2.iscsisrv.*.id[count.index]
  volume_id   = openstack_blockstorage_volume_v3.iscsisrv_sbd.*.id[count.index]
}

module "iscsi_on_destroy" {
  source              = "../../../generic_modules/on_destroy"
  node_count          = var.iscsi_count
  instance_ids        = openstack_compute_instance_v2.iscsisrv.*.id
  user                = var.common_variables["authorized_user"]
  private_key         = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips          = local.provisioning_addresses
  dependencies        = var.on_destroy_dependencies
}
