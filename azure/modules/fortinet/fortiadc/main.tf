locals {
  network_interfaces = {
    "nic-fortiadc_a_1" = { name = "nic-fortiadc_a_1", enable_ip_forwarding = true, enable_accelerated_networking = false, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[1], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[1], ip_configuration_private_ip_offset = 8},
    "nic-fortiadc_a_2" = { name = "nic-fortiadc_a_2", enable_ip_forwarding = true, enable_accelerated_networking = false, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[2], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[2], ip_configuration_private_ip_offset = 8},
    "nic-fortiadc_a_3" = { name = "nic-fortiadc_a_3", enable_ip_forwarding = true, enable_accelerated_networking = false, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[3], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[3], ip_configuration_private_ip_offset = 8},
    "nic-fortiadc_b_1" = { name = "nic-fortiadc_b_1", enable_ip_forwarding = true, enable_accelerated_networking = false, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[1], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[1], ip_configuration_private_ip_offset = 9},
    "nic-fortiadc_b_2" = { name = "nic-fortiadc_b_2", enable_ip_forwarding = true, enable_accelerated_networking = false, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[2], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[2], ip_configuration_private_ip_offset = 9},
    "nic-fortiadc_b_3" = { name = "nic-fortiadc_b_3", enable_ip_forwarding = true, enable_accelerated_networking = false, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[3], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[3], ip_configuration_private_ip_offset = 9},
  }

  /*network_security_groups = {
    "nsg-public"  = { name = "nsg-public" },
    "nsg-private" = { name = "nsg-private" }
  }

  network_security_rules = {
    "nsg-public-inbound-rule" = {
      nsgname                    = "nsg-public",
      rulename                   = "nsg-public-inbound-rule",
      priority                   = "1001",
      direction                  = "Inbound",
      access                     = "Allow",
      protocol                   = "Tcp",
      source_port_range          = "*",
      destination_port_range     = "*",
      source_address_prefix      = "*",
      destination_address_prefix = "*"
    },
    "nsg-private-inbound-rule" = {
      nsgname                    = "nsg-private",
      rulename                   = "nsg-private-inbound-rule",
      priority                   = "1001",
      direction                  = "Inbound",
      access                     = "Allow",
      protocol                   = "*",
      source_port_range          = "*",
      destination_port_range     = "*",
      source_address_prefix      = "*",
      destination_address_prefix = "*"
    }
    "nsg-public-outbound-rule" = {
      nsgname                    = "nsg-public",
      rulename                   = "nsg-public-outbound-rule",
      priority                   = "1001",
      direction                  = "Outbound",
      access                     = "Allow",
      protocol                   = "*",
      source_port_range          = "*",
      destination_port_range     = "*",
      source_address_prefix      = "*",
      destination_address_prefix = "*"
    },
    "nsg-private-outbound-rule" = {
      nsgname                    = "nsg-private",
      rulename                   = "nsg-private-outbound-rule",
      priority                   = "1001",
      direction                  = "Outbound",
      access                     = "Allow",
      protocol                   = "*",
      source_port_range          = "*",
      destination_port_range     = "*",
      source_address_prefix      = "*",
      destination_address_prefix = "*"
    }
  }

  network_security_group_associations = {
    "nic-fortigate_a_1" = { name = "nic-fortigate_a_1", nsgname = "nsg-public" },
    "nic-fortigate_a_2" = { name = "nic-fortigate_a_2", nsgname = "nsg-private" },
    "nic-fortigate_a_3" = { name = "nic-fortigate_a_3", nsgname = "nsg-private" },
    "nic-fortigate_a_4" = { name = "nic-fortigate_a_4", nsgname = "nsg-private" },

    "nic-fortigate_b_1" = { name = "nic-fortigate_b_1", nsgname = "nsg-public" },
    "nic-fortigate_b_2" = { name = "nic-fortigate_b_2", nsgname = "nsg-private" },
    "nic-fortigate_b_3" = { name = "nic-fortigate_b_3", nsgname = "nsg-private" },
    "nic-fortigate_b_4" = { name = "nic-fortigate_b_4", nsgname = "nsg-private" },
  }*/

  lbs = {
    "lb-fadc-internal" = {
      name                                                 = "lb-fadc-internal"
      sku                                                  = "standard"
      frontend_ip_configuration_name                       = "lb-fadc-internal-fe-ip-01"
      frontend_ip_configuration_subnet_id                  = var.snet_ids[1]
      frontend_ip_configuration_private_ip_address_version = "IPv4"
      frontend_ip_configuration_public_ip_address_id       = null
    }
  }

  lb_backend_address_pools = {
    "lb-fadc-internal-be-pool-01" = {
      name            = "lb-fadc-internal-be-pool-01"
      loadbalancer_id = "lb-fadc-internal"
    }
  }

  lb_probes = {
    "lb-fadc-internal-probe" = {
      name                = "lb-fadc-internal-probe"
      loadbalancer_id     = "lb-fadc-internal"
      port                = "8008"
      protocol            = "Tcp"
      interval_in_seconds = "5"
    }
  }

  network_interface_backend_address_pool_associations = {
    "nic-fortiadc_a_1" = {
      network_interface_id    = "nic-fortiadc_a_1"
      ip_configuration_name   = "ipconfig1"
      backend_address_pool_id = "lb-fadc-internal-be-pool-01"
    },
    "nic-fortiadc_b_1" = {
      network_interface_id    = "nic-fortiadc_b_1"
      ip_configuration_name   = "ipconfig1"
      backend_address_pool_id = "lb-fadc-internal-be-pool-01"
    }
  }

  /*vm_configs = {
    "vm-fgt-a" = {
      "name"            = "vm-fgt-a",
      "config_template" = "fgt-config.conf",
      "identity"        = "SystemAssigned",

      "network_interface_ids"        = ["nic-fortigate_a_1", "nic-fortigate_a_2", "nic-fortigate_a_3", "nic-fortigate_a_4"],
      "primary_network_interface_id" = "nic-fortigate_a_1",

      "storage_os_disk_name"              = "disk-fgt-a-os",
      "storage_os_disk_managed_disk_type" = "Premium_LRS",
      "storage_os_disk_create_option"     = "FromImage",
      "storage_os_disk_caching"           = "ReadWrite",

      "storage_data_disk_name"              = "disk-vm-fgt-a-data",
      "storage_data_disk_managed_disk_type" = "Premium_LRS",
      "storage_data_disk_create_option"     = "Empty",
      "storage_data_disk_disk_size_gb"      = "30",
      "storage_data_disk_lun"               = 0,
      "zone"                                = 1,

      "fgt_license_file"    = "${var.fortinet_licenses["fgt_a"]}",
      "fgt_ha_priority"     = "255"
      "fgt_admins_port"     = "443"
      "fgt_license_type"    = var.vm_license
      "fgt_port1_ip"        = cidrhost(var.snet_address_ranges[0], 6)
      "fgt_port1_mask"      = cidrnetmask(var.snet_address_ranges[0])
      "fgt_port1_gateway"   = cidrhost(var.snet_address_ranges[0], 1)
      "fgt_port2_ip"        = cidrhost(var.snet_address_ranges[1], 6)
      "fgt_port2_mask"      = cidrnetmask(var.snet_address_ranges[1])
      "fgt_port2_gateway"   = cidrhost(var.snet_address_ranges[1], 1)
      "fgt_port3_ip"        = cidrhost(var.snet_address_ranges[2], 6)
      "fgt_port3_peerip"    = cidrhost(var.snet_address_ranges[2], 7)
      "fgt_port3_mask"      = cidrnetmask(var.snet_address_ranges[2])
      "fgt_port4_ip"        = cidrhost(var.snet_address_ranges[3], 6)
      "fgt_port4_mask"      = cidrnetmask(var.snet_address_ranges[3])
      "fgt_port4_gateway"   = cidrhost(var.snet_address_ranges[3], 1)
    }
    "vm-fgt-b" = {
      "name"            = "vm-fgt-b",
      "config_template" = "fgt-config.conf",
      "identity"        = "SystemAssigned",

      "network_interface_ids"        = ["nic-fortigate_b_1", "nic-fortigate_b_2", "nic-fortigate_b_3", "nic-fortigate_b_4"],
      "primary_network_interface_id" = "nic-fortigate_b_1",

      "storage_os_disk_name"              = "disk-fgt-b-os",
      "storage_os_disk_managed_disk_type" = "Premium_LRS",
      "storage_os_disk_create_option"     = "FromImage",
      "storage_os_disk_caching"           = "ReadWrite",

      "storage_data_disk_name"              = "disk-vm-fgt-b-data",
      "storage_data_disk_managed_disk_type" = "Premium_LRS",
      "storage_data_disk_create_option"     = "Empty",
      "storage_data_disk_disk_size_gb"      = "30",
      "storage_data_disk_lun"               = 0,
      "zone"                                = 1,

      "fgt_license_file"    = "${var.fortinet_licenses["fgt_b"]}",
      "fgt_ha_priority"     = "1"
      "fgt_admins_port"     = "443"
      "fgt_license_type"    = var.vm_license
      "fgt_port1_ip"        = cidrhost(var.snet_address_ranges[0], 7)
      "fgt_port1_mask"      = cidrnetmask(var.snet_address_ranges[0])
      "fgt_port1_gateway"   = cidrhost(var.snet_address_ranges[0], 1)
      "fgt_port2_ip"        = cidrhost(var.snet_address_ranges[1], 7)
      "fgt_port2_mask"      = cidrnetmask(var.snet_address_ranges[1])
      "fgt_port2_gateway"   = cidrhost(var.snet_address_ranges[1], 1)
      "fgt_port3_ip"        = cidrhost(var.snet_address_ranges[2], 7)
      "fgt_port3_peerip"    = cidrhost(var.snet_address_ranges[2], 6)
      "fgt_port3_mask"      = cidrnetmask(var.snet_address_ranges[2])
      "fgt_port4_ip"        = cidrhost(var.snet_address_ranges[3], 7)
      "fgt_port4_mask"      = cidrnetmask(var.snet_address_ranges[3])
      "fgt_port4_gateway"   = cidrhost(var.snet_address_ranges[3], 1)
    }
  }*/
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

resource "azurerm_network_interface_backend_address_pool_association" "network_interface_backend_address_pool_association" {
  for_each = local.network_interface_backend_address_pool_associations

  network_interface_id    = azurerm_network_interface.network_interface[each.value.network_interface_id].id
  ip_configuration_name   = each.value.ip_configuration_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool[each.value.backend_address_pool_id].id

  depends_on = [
    azurerm_network_interface.network_interface
    /*azurerm_virtual_machine.virtual_machine*/
  ]
}

