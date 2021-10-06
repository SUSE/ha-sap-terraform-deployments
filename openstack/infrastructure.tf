# Configure the OpenStack Provider
provider "openstack" {
}

terraform {
  required_version = ">= 0.13"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
    template = {
      source = "hashicorp/template"
    }
  }
}

variable openstack_auth_url {
  description = "OpenStack Keystone auth_url for Kubernetes Provider Plugin"
}

variable openstack_password {
  description = "OpenStack Keystone Password for Kubernetes Provider Plugin"
}

# get OpenStack Scope information
data "openstack_identity_auth_scope_v3" "scope" {
  name = "auth_scope"
}

data "openstack_networking_network_v2" "current-subnet" {
  count  = var.ip_cidr_range == "" ? 1 : 0
  name   = var.subnet_name
  region = var.region_net
}

locals {
  deployment_name = var.deployment_name != "" ? var.deployment_name : terraform.workspace

  network_name         = var.network_name == "" ? openstack_networking_network_v2.ha_network.0.name : var.network_name
  network_id           = var.network_id == "" ? openstack_networking_network_v2.ha_network.0.id : var.network_id
  subnet_name          = var.subnet_name == "" ? openstack_networking_subnet_v2.ha_subnet.0.name : var.subnet_name
  subnet_id            = var.subnet_id == "" ? openstack_networking_subnet_v2.ha_subnet.0.id : var.subnet_id
  subnet_address_range = var.ip_cidr_range
}

# Network resources: L3 router and interfaces
resource "openstack_networking_router_v2" "router" {
  name                    = "${local.deployment_name}-router"
  admin_state_up          = "true"
  external_network_id     = var.external_network_id
  availability_zone_hints = [var.region_net]
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.ha_subnet.0.id
}

# Network resources: Network, Subnet
resource "openstack_networking_network_v2" "ha_network" {
  count                   = var.network_name == "" ? 1 : 0
  name                    = "${local.deployment_name}-network"
  admin_state_up          = "true"
  availability_zone_hints = [var.region_net]
}

resource "openstack_networking_subnet_v2" "ha_subnet" {
  count      = var.subnet_name == "" ? 1 : 0
  name       = "${local.deployment_name}-subnet"
  network_id = openstack_networking_network_v2.ha_network.0.id
  cidr       = local.subnet_address_range
  ip_version = 4
}

# Network firewall rules
resource "openstack_networking_secgroup_v2" "ha_firewall_external" {
  name = "${local.deployment_name}-fw-external"
}

resource "openstack_networking_secgroup_rule_v2" "ha_firewall_allow_icmp" {
  count             = var.create_firewall_rules ? 1 : 0
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.ha_firewall_external.id
}

resource "openstack_networking_secgroup_rule_v2" "ha_firewall_allow_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.ha_firewall_external.id
}

resource "openstack_networking_secgroup_v2" "ha_firewall_internal" {
  name = "${local.deployment_name}-fw-internal"
}

resource "openstack_networking_secgroup_rule_v2" "ha_firewall_internal_allow_all" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = local.subnet_address_range
  security_group_id = openstack_networking_secgroup_v2.ha_firewall_internal.id
}


# Bastion

module "bastion" {
  source           = "./modules/bastion"
  common_variables = module.common_variables.configuration
  name             = var.bastion_name
  network_domain   = var.bastion_network_domain == "" ? var.network_domain : var.bastion_network_domain
  region           = var.region
  region_net       = var.region_net

  bastion_flavor         = var.bastion_flavor
  network_name           = local.network_name
  network_id             = local.network_id
  network_subnet_name    = local.subnet_name
  network_subnet_id      = local.subnet_id
  firewall_external      = openstack_networking_secgroup_v2.ha_firewall_external.id
  firewall_internal      = openstack_networking_secgroup_v2.ha_firewall_internal.id
  os_image               = local.bastion_os_image
  bastion_srv_ip         = var.bastion_srv_ip
  bastion_data_disk_name = var.bastion_data_disk_name
  bastion_data_disk_type = var.bastion_data_disk_type
  bastion_data_disk_size = var.bastion_data_disk_size
  floatingip_pool        = var.floatingip_pool
  router_interface_1     = openstack_networking_router_interface_v2.router_interface_1.id
  on_destroy_dependencies = [
    openstack_networking_router_v2.router,
    openstack_networking_router_interface_v2.router_interface_1,
    openstack_networking_secgroup_v2.ha_firewall_external,
    openstack_networking_secgroup_rule_v2.ha_firewall_allow_ssh
  ]
}
