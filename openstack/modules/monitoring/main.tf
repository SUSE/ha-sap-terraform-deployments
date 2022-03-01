# monitoring deployment in openstack

locals {
  bastion_enabled        = var.common_variables["bastion_enabled"]
  vm_count               = var.monitoring_enabled == "true" ? 0 : 1
  provisioning_addresses = openstack_compute_instance_v2.monitoring.*.access_ip_v4
  hostname               = var.common_variables["deployment_name_in_hostname"] ? format("%s-%s", var.common_variables["deployment_name"], var.name) : var.name
}

resource "openstack_networking_port_v2" "monitoring" {
  count = local.vm_count
  name  = "${var.common_variables["deployment_name"]}-monitoring-port-${count.index + 1}"

  network_id     = var.network_id
  admin_state_up = "true"
  fixed_ip {
    subnet_id  = var.network_subnet_id
    ip_address = var.host_ips[count.index]
  }
  security_group_ids = [var.firewall_internal]
}

resource "openstack_compute_instance_v2" "monitoring" {
  count        = local.vm_count
  name         = "${var.common_variables["deployment_name"]}-${var.name}"
  flavor_name  = var.flavor
  image_id     = var.os_image
  config_drive = true
  user_data    = var.userdata
  key_pair     = "terraform"
  depends_on   = [openstack_networking_port_v2.monitoring]
  network {
    port = openstack_networking_port_v2.monitoring[count.index].id
  }
  availability_zone = var.region
}

module "monitoring_on_destroy" {
  source              = "../../../generic_modules/on_destroy"
  node_count          = local.vm_count
  instance_ids        = openstack_compute_instance_v2.monitoring.*.id
  user                = var.common_variables["authorized_user"]
  private_key         = var.common_variables["private_key"]
  bastion_host        = var.bastion_host
  bastion_private_key = var.common_variables["bastion_private_key"]
  public_ips          = openstack_networking_port_v2.monitoring.*.fixed_ip.0.ip_address
  dependencies        = var.on_destroy_dependencies
}
