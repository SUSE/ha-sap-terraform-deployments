# netweaver deployment in openstack

locals {
  bastion_enabled        = var.common_variables["bastion_enabled"]
  vm_count               = var.xscs_server_count + var.app_server_count
  create_ha_infra        = local.vm_count > 1 && var.common_variables["hana"]["ha_enabled"] ? 1 : 0
  provisioning_addresses = openstack_compute_instance_v2.netweaver.*.access_ip_v4
  hostname               = var.common_variables["deployment_name_in_hostname"] ? format("%s-%s", var.common_variables["deployment_name"], var.name) : var.name
}

resource "openstack_networking_port_v2" "netweaver" {
  count = local.vm_count
  name  = "${var.common_variables["deployment_name"]}-netweaver-port-${count.index + 1}"

  network_id     = var.network_id
  admin_state_up = "true"
  fixed_ip {
    subnet_id  = var.network_subnet_id
    ip_address = var.host_ips[count.index]
  }
  allowed_address_pairs {
    ip_address = var.virtual_host_ips[0]
  }
  allowed_address_pairs {
    ip_address = var.virtual_host_ips[0]
  }
  allowed_address_pairs {
    ip_address = var.virtual_host_ips[0]
  }
  allowed_address_pairs {
    ip_address = var.virtual_host_ips[0]
  }
  security_group_ids = [var.firewall_internal]
}

resource "openstack_compute_instance_v2" "netweaver" {
  count        = local.vm_count
  name         = "${var.common_variables["deployment_name"]}-${var.name}${format("%02d", count.index + 1)}"
  flavor_name  = var.flavor
  image_id     = var.os_image
  config_drive = true
  user_data    = var.userdata
  key_pair     = "terraform"
  depends_on   = [openstack_networking_port_v2.netweaver]
  network {
    port = openstack_networking_port_v2.netweaver[count.index].id
  }
  availability_zone = var.region
}

module "netweaver_on_destroy" {
  source              = "../../../generic_modules/on_destroy"
  node_count          = local.vm_count
  instance_ids        = openstack_compute_instance_v2.netweaver.*.id
  user                = var.common_variables["authorized_user"]
  private_key         = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips          = openstack_networking_port_v2.netweaver.*.fixed_ip.0.ip_address
  dependencies        = var.on_destroy_dependencies
}
