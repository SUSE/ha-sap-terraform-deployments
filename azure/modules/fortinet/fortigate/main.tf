locals {
  fgt_public_ips = {
    "pip-fgt" = { name = "pip-fgt", allocation_method = "Static", sku = "Standard" }
  }

  network_interfaces = {
    "nic-fortigate_a_1" = { name = "nic-fortigate_a_1", enable_ip_forwarding = true, enable_accelerated_networking = true, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[0], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[0], ip_configuration_private_ip_offset = 6, nsgname = "nsg-public" },
    "nic-fortigate_a_2" = { name = "nic-fortigate_a_2", enable_ip_forwarding = true, enable_accelerated_networking = true, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[1], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[1], ip_configuration_private_ip_offset = 6, nsgname = "nsg-private" },
    "nic-fortigate_a_3" = { name = "nic-fortigate_a_3", enable_ip_forwarding = true, enable_accelerated_networking = true, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[2], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[2], ip_configuration_private_ip_offset = 6, nsgname = "nsg-private" },
    "nic-fortigate_a_4" = { name = "nic-fortigate_a_4", enable_ip_forwarding = true, enable_accelerated_networking = true, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[3], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[3], ip_configuration_private_ip_offset = 6, nsgname = "nsg-private" },
    "nic-fortigate_b_1" = { name = "nic-fortigate_b_1", enable_ip_forwarding = true, enable_accelerated_networking = true, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[0], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[0], ip_configuration_private_ip_offset = 7, nsgname = "nsg-public" },
    "nic-fortigate_b_2" = { name = "nic-fortigate_b_2", enable_ip_forwarding = true, enable_accelerated_networking = true, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[1], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[1], ip_configuration_private_ip_offset = 7, nsgname = "nsg-private" },
    "nic-fortigate_b_3" = { name = "nic-fortigate_b_3", enable_ip_forwarding = true, enable_accelerated_networking = true, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[2], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[2], ip_configuration_private_ip_offset = 7, nsgname = "nsg-private" },
    "nic-fortigate_b_4" = { name = "nic-fortigate_b_4", enable_ip_forwarding = true, enable_accelerated_networking = true, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[3], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[3], ip_configuration_private_ip_offset = 7, nsgname = "nsg-private" },
  }

  network_security_groups = {
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

  lb_nat_rules = {
    "lb-nat-rule-fgt-a-mgmt" = {
      name                           = "lb-nat-rule-fgt-a-mgmt"
      resource_group_name            = var.resource_group_name
      loadbalancer_id                = "lb-fgt-external"
      protocol                       = "Tcp"
      frontend_port                  = 40443
      backend_port                   = 443
      frontend_ip_configuration_name = "lb-fgt-external-fe-ip-01"
    },
    "lb-nat-rule-fgt-b-mgmt" = {
      name                           = "lb-nat-rule-fgt-b-mgmt"
      resource_group_name            = var.resource_group_name
      loadbalancer_id                = "lb-fgt-external"
      protocol                       = "Tcp"
      frontend_port                  = 50443
      backend_port                   = 443
      frontend_ip_configuration_name = "lb-fgt-external-fe-ip-01"
    }
  }

  network_interface_nat_rule_associations = {
    "lb-nat-rule-fgt-a-mgmt-association" = {
      network_interface_id  = "nic-fortigate_a_4"
      ip_configuration_name = "ipconfig1"
      nat_rule_id           = "lb-nat-rule-fgt-a-mgmt"
    },
    "lb-nat-rule-fgt-b-mgmt-association" = {
      network_interface_id  = "nic-fortigate_b_4"
      ip_configuration_name = "ipconfig1"
      nat_rule_id           = "lb-nat-rule-fgt-b-mgmt"
    }

  }

  vm_configs = {
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

      "fgt_license_file"    = "${var.fortinet_licenses["license_a"]}",
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

      "fgt_license_file"    = "${var.fortinet_licenses["license_b"]}",
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

resource "azurerm_network_security_group" "network_security_group" {
  for_each = local.network_security_groups

  name                = each.value.name
  location            = var.az_region
  resource_group_name = var.resource_group_name

  depends_on = [
    azurerm_network_interface.network_interface
  ]
}

resource "azurerm_network_security_rule" "network_security_rule" {
  for_each = local.network_security_rules

  name                        = each.value.rulename
  network_security_group_name = azurerm_network_security_group.network_security_group[each.value.nsgname].name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = var.resource_group_name
}

resource "azurerm_network_interface_security_group_association" "network_interface_security_group_association" {
  for_each = local.network_security_group_associations

  network_interface_id      = azurerm_network_interface.network_interface[each.value.name].id
  network_security_group_id = azurerm_network_security_group.network_security_group[each.value.nsgname].id

  depends_on = [
    azurerm_network_interface.network_interface
  ]
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

  depends_on = [
    azurerm_network_interface.network_interface,
    azurerm_virtual_machine.virtual_machine
  ]
}

resource "azurerm_lb_nat_rule" "lb_nat_rule" {

  for_each = local.lb_nat_rules

  name                           = each.value.name
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.lb[each.value.loadbalancer_id].id
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
}

resource "azurerm_network_interface_nat_rule_association" "network_interface_nat_rule_association" {

  for_each = local.network_interface_nat_rule_associations

  network_interface_id  = azurerm_network_interface.network_interface[each.value.network_interface_id].id
  ip_configuration_name = each.value.ip_configuration_name
  nat_rule_id           = azurerm_lb_nat_rule.lb_nat_rule[each.value.nat_rule_id].id
}

resource "azurerm_marketplace_agreement" "marketplace_agreement" {
  publisher = var.vm_publisher
  offer     = var.vm_offer
  plan      = var.vm_sku
}
resource "azurerm_virtual_machine" "virtual_machine" {
  for_each                     = local.vm_configs

  name                         = each.value.name
  location                     = var.az_region
  resource_group_name          = var.resource_group_name
  network_interface_ids        = [for nic in each.value.network_interface_ids : azurerm_network_interface.network_interface[nic].id]
  primary_network_interface_id = azurerm_network_interface.network_interface[each.value.primary_network_interface_id].id
  vm_size                      = var.vm_size

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  boot_diagnostics {
    enabled     = true
    storage_uri = var.storage_account
  }

  identity {
    type = each.value.identity
  }

  storage_image_reference {
    publisher = var.vm_publisher
    offer     = var.vm_offer
    sku       = var.vm_sku
    version   = var.vm_version
  }

  plan {
    publisher = var.vm_publisher
    product   = var.vm_offer
    name      = var.vm_sku
  }

  storage_os_disk {
    name              = each.value.storage_os_disk_name
    managed_disk_type = each.value.storage_os_disk_managed_disk_type
    create_option     = each.value.storage_os_disk_create_option
    caching           = each.value.storage_os_disk_caching
  }

  storage_data_disk {
    name              = each.value.storage_data_disk_name
    managed_disk_type = each.value.storage_data_disk_managed_disk_type
    create_option     = each.value.storage_data_disk_create_option
    disk_size_gb      = each.value.storage_data_disk_disk_size_gb
    lun               = each.value.storage_data_disk_lun
  }
  os_profile {
    computer_name  = each.value.name
    admin_username = var.vm_username
    admin_password = var.vm_password
    custom_data    = data.template_file.fgt_customdata[each.key].rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  zones = [each.value.zone]

  depends_on = [
    azurerm_network_interface.network_interface
  ]
}

data "template_file" "fgt_customdata" {
  for_each = local.vm_configs
  template = file("${path.module}/${each.value.config_template}")
  vars = {
    fgt_id              = each.value.name
    fgt_license_file    = each.value.fgt_license_file
    fgt_ha_priority     = each.value.fgt_ha_priority
    fgt_admins_port     = each.value.fgt_admins_port
    fgt_license_type    = each.value.fgt_license_type
    fgt_port1_ip        = each.value.fgt_port1_ip
    fgt_port1_mask      = each.value.fgt_port1_mask
    fgt_port1_gateway   = each.value.fgt_port1_gateway
    fgt_port2_ip        = each.value.fgt_port2_ip
    fgt_port2_mask      = each.value.fgt_port2_mask
    fgt_port2_gateway   = each.value.fgt_port2_gateway
    fgt_port3_ip        = each.value.fgt_port3_ip
    fgt_port3_mask      = each.value.fgt_port3_mask
    fgt_port3_peerip    = each.value.fgt_port3_peerip
    fgt_port4_ip        = each.value.fgt_port4_ip
    fgt_port4_mask      = each.value.fgt_port4_mask
    fgt_port4_gateway   = each.value.fgt_port4_gateway
    fgt_vnet            = var.vnet_address_range
  }
}
