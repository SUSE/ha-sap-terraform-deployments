locals {
  fgt_public_ips = {
    "pip-fgt" = { name = "pip-fgt", allocation_method = "Static", sku = "Standard" }
  }

  network_interfaces = {
    "nic-fortigate_a_1" = { name = "nic-fortigate_a_1", enable_ip_forwarding = true, enable_accelerated_networking = true, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[0], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[0], ip_configuration_private_ip_offset = 6, nsgname = "public_nsg_group" },
    "nic-fortigate_a_2" = { name = "nic-fortigate_a_2", enable_ip_forwarding = true, enable_accelerated_networking = true, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[1], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[1], ip_configuration_private_ip_offset = 6, nsgname = "private_nsg_group" },
    "nic-fortigate_a_3" = { name = "nic-fortigate_a_3", enable_ip_forwarding = true, enable_accelerated_networking = true, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[2], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[2], ip_configuration_private_ip_offset = 6, nsgname = "private_nsg_group" },
    "nic-fortigate_a_4" = { name = "nic-fortigate_a_4", enable_ip_forwarding = true, enable_accelerated_networking = true, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[3], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[3], ip_configuration_private_ip_offset = 6, nsgname = "public_nsg_group" },
    "nic-fortigate_b_1" = { name = "nic-fortigate_b_1", enable_ip_forwarding = true, enable_accelerated_networking = true, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[0], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[0], ip_configuration_private_ip_offset = 7, nsgname = "public_nsg_group" },
    "nic-fortigate_b_2" = { name = "nic-fortigate_b_2", enable_ip_forwarding = true, enable_accelerated_networking = true, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[1], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[1], ip_configuration_private_ip_offset = 7, nsgname = "private_nsg_group" },
    "nic-fortigate_b_3" = { name = "nic-fortigate_b_3", enable_ip_forwarding = true, enable_accelerated_networking = true, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[2], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[2], ip_configuration_private_ip_offset = 7, nsgname = "private_nsg_group" },
    "nic-fortigate_b_4" = { name = "nic-fortigate_b_4", enable_ip_forwarding = true, enable_accelerated_networking = true, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[3], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[3], ip_configuration_private_ip_offset = 7, nsgname = "public_nsg_group" },
  }
  lbs = {
    "lb-fgt-external" = {
      name                                                 = "lb-fgt-external",
      sku                                                  = "standard",
      frontend_ip_configuration_name                       = "lb-fgt-external-fe-ip-01"
      frontend_ip_configuration_subnet_id                  = null
      frontend_ip_configuration_private_ip_address_version = null
      frontend_ip_configuration_public_ip_address_id       = azurerm_public_ip.public_ip["pip-fgt"].id
    },
    "lb-fgt-internal" = {
      name                                                 = "lb-fgt-internal",
      sku                                                  = "standard",
      frontend_ip_configuration_name                       = "lb-fgt-internal-fe-ip-01"
      frontend_ip_configuration_subnet_id                  = var.snet_ids[1]
      frontend_ip_configuration_private_ip_address_version = "IPv4"
      frontend_ip_configuration_public_ip_address_id       = null
    }
  }

  lb_backend_address_pools = {
    "lb-fgt-external-be-pool-01" = {
      name            = "lb-fgt-external-be-pool-01"
      loadbalancer_id = "lb-fgt-external"
    },
    "lb-fgt-internal-be-pool-01" = {
      name            = "lb-fgt-internal-be-pool-01"
      loadbalancer_id = "lb-fgt-internal"
    }
  }

  lb_probes = {
    "lb-fgt-external-probe" = {
      name                = "lb-fgt-external-probe"
      loadbalancer_id     = "lb-fgt-external"
      port                = "8008"
      protocol            = "Tcp"
      interval_in_seconds = "5"
    },
    "lb-fgt-internal-probe" = {
      name                = "lb-fgt-internal-probe"
      loadbalancer_id     = "lb-fgt-internal"
      port                = "8008"
      protocol            = "Tcp"
      interval_in_seconds = "5"
    }
  }

  lb_rules = {
    "lb-fgt-external-rule-443" = {
      name                           = "lb-fgt-extrenal-rule-443"
      loadbalancer_id                = "lb-fgt-external"
      protocol                       = "Tcp"
      frontend_port                  = 443
      backend_port                   = 443
      frontend_ip_configuration_name = "lb-fgt-external-fe-ip-01"
      probe_id                       = "lb-fgt-external-probe"
      backend_address_pool_id        = "lb-fgt-external-be-pool-01"
      enable_floating_ip             = false
      disable_outbound_snat          = true
    }
  }

  network_interface_backend_address_pool_associations = {
    "nic-fortigate_a_1" = {
      network_interface_id    = "nic-fortigate_a_1"
      ip_configuration_name   = "ipconfig1"
      backend_address_pool_id = "lb-fgt-external-be-pool-01"
    },
    "nic-fortigate_b_1" = {
      network_interface_id    = "nic-fortigate_b_1"
      ip_configuration_name   = "ipconfig1"
      backend_address_pool_id = "lb-fgt-external-be-pool-01"
    },
    "nic-fortigate_a_2" = {
      network_interface_id    = "nic-fortigate_a_2"
      ip_configuration_name   = "ipconfig1"
      backend_address_pool_id = "lb-fgt-internal-be-pool-01"
    },
    "nic-fortigate_b_2" = {
      network_interface_id    = "nic-fortigate_b_2"
      ip_configuration_name   = "ipconfig1"
      backend_address_pool_id = "lb-fgt-internal-be-pool-01"
    }
  }
}

resource "azurerm_public_ip" "public_ip" {

  for_each = local.fgt_public_ips

  name                = each.value.name
  location            = var.az_region
  resource_group_name = var.resource_group_name
  allocation_method   = each.value.allocation_method
  sku                 = each.value.sku
}
resource "azurerm_network_interface" "network_interface" {
  for_each = local.network_interfaces

  name                          = each.value.name
  location                      = var.az_region
  resource_group_name           = var.resource_group_name
  enable_ip_forwarding          = each.value.enable_ip_forwarding
  enable_accelerated_networking = each.value.enable_accelerated_networking

  ip_configuration {
    name                          = each.value.ip_configuration_name
    subnet_id                     = each.value.ip_configuration_subnet_id
    private_ip_address_allocation = each.value.ip_configuration_private_ip_address_allocation
    private_ip_address            = cidrhost(each.value.ip_configuration_private_ip_address, each.value.ip_configuration_private_ip_offset)
  }
}

resource "azurerm_lb" "lb" {
  for_each = local.lbs

  name                = each.value.name
  sku                 = each.value.sku
  location            = var.az_region
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                       = each.value.frontend_ip_configuration_name
    subnet_id                  = each.value.frontend_ip_configuration_subnet_id
    private_ip_address_version = each.value.frontend_ip_configuration_private_ip_address_version
    public_ip_address_id       = each.value.frontend_ip_configuration_public_ip_address_id == null ? null : each.value.frontend_ip_configuration_public_ip_address_id
  }
}

resource "azurerm_lb_backend_address_pool" "lb_backend_address_pool" {
  for_each = local.lb_backend_address_pools

  name                = each.value.name
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.lb[each.value.loadbalancer_id].id
}

resource "azurerm_lb_probe" "lb_probe" {
  for_each = local.lb_probes

  name                = each.value.name
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.lb[each.value.loadbalancer_id].id
  port                = each.value.port
  protocol            = each.value.protocol
  interval_in_seconds = each.value.interval_in_seconds
}

resource "azurerm_lb_rule" "lb_rule" {
  for_each = local.lb_rules

  name                           = each.value.name
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.lb[each.value.loadbalancer_id].id
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  probe_id                       = azurerm_lb_probe.lb_probe[each.value.probe_id].id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lb_backend_address_pool[each.value.backend_address_pool_id].id
  enable_floating_ip             = each.value.enable_floating_ip
  disable_outbound_snat          = each.value.disable_outbound_snat
}

resource "azurerm_network_interface_backend_address_pool_association" "network_interface_backend_address_pool_association" {
  for_each = local.network_interface_backend_address_pool_associations

  network_interface_id    = azurerm_network_interface.network_interface[each.value.network_interface_id].id
  ip_configuration_name   = each.value.ip_configuration_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool[each.value.backend_address_pool_id].id
}
