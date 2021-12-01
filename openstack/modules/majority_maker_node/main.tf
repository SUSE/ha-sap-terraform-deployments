# majority maker deployment in OpenStack

locals {
  bastion_enabled      = var.common_variables["bastion_enabled"]
  provisioning_address = openstack_compute_instance_v2.majority_maker.*.access_ip_v4
  hostname             = var.common_variables["deployment_name_in_hostname"] ? format("%s-%s", var.common_variables["deployment_name"], var.name) : var.name
}

resource "openstack_networking_port_v2" "majority_maker" {
  count = var.node_count
  name  = "${var.common_variables["deployment_name"]}-mm-port-${count.index + 1}"

  network_id     = var.network_id
  admin_state_up = "true"
  fixed_ip {
    subnet_id  = var.network_subnet_id
    ip_address = var.majority_maker_ip
  }
  allowed_address_pairs {
    ip_address = var.common_variables["hana"]["cluster_vip"]
  }
  allowed_address_pairs {
    ip_address = var.common_variables["hana"]["cluster_vip_secondary"]
  }
  security_group_ids = [var.firewall_internal]
}

resource "openstack_compute_instance_v2" "majority_maker" {
  count        = var.node_count
  name         = "${var.common_variables["deployment_name"]}-${var.name}mm"
  flavor_name  = var.flavor
  image_id     = var.os_image
  config_drive = true
  user_data    = var.userdata
  key_pair     = "terraform"
  depends_on   = [openstack_networking_port_v2.majority_maker]
  network {
    port = openstack_networking_port_v2.majority_maker[count.index].id
  }
  availability_zone = var.region
}

module "majority_maker_on_destroy" {
  source              = "../../../generic_modules/on_destroy"
  node_count          = var.node_count
  instance_ids        = openstack_compute_instance_v2.majority_maker.*.id
  user                = var.common_variables["authorized_user"]
  private_key         = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips          = openstack_networking_port_v2.majority_maker.*.fixed_ip.0.ip_address
  dependencies        = var.on_destroy_dependencies
}
