locals {
  network_interfaces = {
    "nic-fortiadc_a_1" = { name = "nic-fortiadc_a_1", enable_ip_forwarding = true, enable_accelerated_networking = false, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[1], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[1], ip_configuration_private_ip_offset = 8},
    "nic-fortiadc_a_2" = { name = "nic-fortiadc_a_2", enable_ip_forwarding = true, enable_accelerated_networking = false, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[2], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[2], ip_configuration_private_ip_offset = 8},
    "nic-fortiadc_a_3" = { name = "nic-fortiadc_a_3", enable_ip_forwarding = true, enable_accelerated_networking = false, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[3], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[3], ip_configuration_private_ip_offset = 8},
    "nic-fortiadc_b_1" = { name = "nic-fortiadc_b_1", enable_ip_forwarding = true, enable_accelerated_networking = false, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[1], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[1], ip_configuration_private_ip_offset = 9},
    "nic-fortiadc_b_2" = { name = "nic-fortiadc_b_2", enable_ip_forwarding = true, enable_accelerated_networking = false, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[2], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[2], ip_configuration_private_ip_offset = 9},
    "nic-fortiadc_b_3" = { name = "nic-fortiadc_b_3", enable_ip_forwarding = true, enable_accelerated_networking = false, ip_configuration_name = "ipconfig1", ip_configuration_subnet_id = var.snet_ids[3], ip_configuration_private_ip_address_allocation = "Static", ip_configuration_private_ip_address = var.snet_address_ranges[3], ip_configuration_private_ip_offset = 9},
  }

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

  vm_configs = {
    "vm-fadc-a" = {
      "name"            = "vm-fadc-a",
      "config_template" = "fadc-config.conf",
      "identity"        = "SystemAssigned",

      "network_interface_ids"        = ["nic-fortiadc_a_1", "nic-fortiadc_a_2", "nic-fortiadc_a_3"],
      "primary_network_interface_id" = "nic-fortiadc_a_1",

      "storage_os_disk_name"              = "disk-fadc-a-os",
      "storage_os_disk_managed_disk_type" = "Premium_LRS",
      "storage_os_disk_create_option"     = "FromImage",
      "storage_os_disk_caching"           = "ReadWrite",

      "storage_data_disk_name"              = "disk-vm-fadc-a-data",
      "storage_data_disk_managed_disk_type" = "Premium_LRS",
      "storage_data_disk_create_option"     = "Empty",
      "storage_data_disk_disk_size_gb"      = "30",
      "storage_data_disk_lun"               = 0,
      "zone"                                = 1,

      "fadc_license_file"    = "${var.fortinet_licenses["license_a"]}"

      "fadc_config_ha"   = true,
      "fadc_ha_localip"  = cidrhost(var.snet_address_ranges[1], 8)
      "fadc_ha_peerip"   = cidrhost(var.snet_address_ranges[1], 9)
      "fadc_ha_nodeid"   = "5",
      "fadc_a_ha_nodeid" = "0",
      "fadc_b_ha_nodeid" = "1",
      "fadc_ha_nodeid"   = "0"
    }
    "vm-fadc-b" = {
      "name"            = "vm-fadc-b",
      "config_template" = "fadc-config.conf",
      "identity"        = "SystemAssigned",

      "network_interface_ids"        = ["nic-fortiadc_b_1", "nic-fortiadc_b_2", "nic-fortiadc_b_3"],
      "primary_network_interface_id" = "nic-fortiadc_b_1",

      "storage_os_disk_name"              = "disk-fadc-b-os",
      "storage_os_disk_managed_disk_type" = "Premium_LRS",
      "storage_os_disk_create_option"     = "FromImage",
      "storage_os_disk_caching"           = "ReadWrite",

      "storage_data_disk_name"              = "disk-vm-fadc-b-data",
      "storage_data_disk_managed_disk_type" = "Premium_LRS",
      "storage_data_disk_create_option"     = "Empty",
      "storage_data_disk_disk_size_gb"      = "30",
      "storage_data_disk_lun"               = 0,
      "zone"                                = 1,

      "fadc_license_file"    = "${var.fortinet_licenses["license_b"]}"

      "fadc_config_ha"   = true,
      "fadc_ha_localip"  = cidrhost(var.snet_address_ranges[1], 9)
      "fadc_ha_peerip"   = cidrhost(var.snet_address_ranges[1], 8)
      "fadc_ha_nodeid"   = "9",
      "fadc_a_ha_nodeid" = "0",
      "fadc_b_ha_nodeid" = "1",
      "fadc_ha_nodeid"   = "1"
    }
  }
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
    azurerm_network_interface.network_interface,
    azurerm_virtual_machine.virtual_machine
  ]
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
    custom_data    = data.template_file.fadc_customdata[each.key].rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  zones = [each.value.zone]

  depends_on = [
    azurerm_network_interface.network_interface
  ]
}

data "template_file" "fadc_customdata" {
  for_each = local.vm_configs
  template = file("${path.module}/${each.value.config_template}")
  vars = {
    fadc_id           = each.value.name
    fadc_license_file = each.value.fadc_license_file
    fadc_config_ha    = true

    fadc_ha_localip  = each.value.fadc_ha_localip
    fadc_ha_peerip   = each.value.fadc_ha_peerip
    fadc_ha_priority = each.value.fadc_ha_nodeid
    fadc_a_ha_nodeid = each.value.fadc_a_ha_nodeid
    fadc_b_ha_nodeid = each.value.fadc_b_ha_nodeid
    fadc_ha_nodeid   = each.value.fadc_ha_nodeid
  }
}
