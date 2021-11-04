locals {
  network_interfaces = {
    "nic-fortiadc_a_1" = {
      name                                           = "nic-fortiadc_a_1"
      location                                       = var.az_region
      resource_group_name                            = var.resource_group_name
      enable_ip_forwarding                           = true
      enable_accelerated_networking                  = true
      ip_configuration_name                          = "ipconfig1"
      ip_configuration_public_ip_address_id          = null
      ip_configuration_subnet_id                     = var.snet_ids["shared-services"]
      ip_configuration_private_ip_address_allocation = "Static"
      ip_configuration_private_ip_address            = cidrhost(var.snet_address_ranges["shared-services"], 8)
    }
    "nic-fortiadc_a_2" = {
      name                                           = "nic-fortiadc_a_2"
      location                                       = var.az_region
      resource_group_name                            = var.resource_group_name
      enable_ip_forwarding                           = true
      enable_accelerated_networking                  = true
      ip_configuration_name                          = "ipconfig1"
      ip_configuration_public_ip_address_id          = null
      ip_configuration_subnet_id                     = var.snet_ids["hasync"]
      ip_configuration_private_ip_address_allocation = "Static"
      ip_configuration_private_ip_address            = cidrhost(var.snet_address_ranges["hasync"], 8)
    }
    "nic-fortiadc_a_3" = {
      name                                           = "nic-fortiadc_a_3"
      location                                       = var.az_region
      resource_group_name                            = var.resource_group_name
      enable_ip_forwarding                           = true
      enable_accelerated_networking                  = true
      ip_configuration_name                          = "ipconfig1"
      ip_configuration_public_ip_address_id          = null
      ip_configuration_subnet_id                     = var.snet_ids["fortinet-mgmt"]
      ip_configuration_private_ip_address_allocation = "Static"
      ip_configuration_private_ip_address            = cidrhost(var.snet_address_ranges["fortinet-mgmt"], 8)
    }
    "nic-fortiadc_b_1" = {
      name                                           = "nic-fortiadc_b_1"
      location                                       = var.az_region
      resource_group_name                            = var.resource_group_name
      enable_ip_forwarding                           = true
      enable_accelerated_networking                  = true
      ip_configuration_name                          = "ipconfig1"
      ip_configuration_public_ip_address_id          = null
      ip_configuration_subnet_id                     = var.snet_ids["shared-services"]
      ip_configuration_private_ip_address_allocation = "Static"
      ip_configuration_private_ip_address            = cidrhost(var.snet_address_ranges["shared-services"], 9)
    }
    "nic-fortiadc_b_2" = {
      name                                           = "nic-fortiadc_b_2"
      location                                       = var.az_region
      resource_group_name                            = var.resource_group_name
      enable_ip_forwarding                           = true
      enable_accelerated_networking                  = true
      ip_configuration_name                          = "ipconfig1"
      ip_configuration_public_ip_address_id          = null
      ip_configuration_subnet_id                     = var.snet_ids["hasync"]
      ip_configuration_private_ip_address_allocation = "Static"
      ip_configuration_private_ip_address            = cidrhost(var.snet_address_ranges["hasync"], 9)
    }
    "nic-fortiadc_b_3" = {
      name                                           = "nic-fortiadc_b_3"
      location                                       = var.az_region
      resource_group_name                            = var.resource_group_name
      enable_ip_forwarding                           = true
      enable_accelerated_networking                  = true
      ip_configuration_name                          = "ipconfig1"
      ip_configuration_public_ip_address_id          = null
      ip_configuration_subnet_id                     = var.snet_ids["fortinet-mgmt"]
      ip_configuration_private_ip_address_allocation = "Static"
      ip_configuration_private_ip_address            = cidrhost(var.snet_address_ranges["fortinet-mgmt"], 9)
    }
  }

  lbs = {
    "lb-fadc-internal" = {
      name                                                 = "lb-fadc-internal"
      location                                             = var.az_region
      resource_group_name                                  = var.resource_group_name
      sku                                                  = "standard"
      frontend_ip_configuration_name                       = "lb-fadc-internal-fe-ip-01"
      frontend_ip_configuration_subnet_id                  = var.snet_ids["shared-services"]
      frontend_ip_configuration_private_ip_address_version = "IPv4"
      frontend_ip_configuration_public_ip_address_id       = null
    }
  }

  lb_backend_address_pools = {
    "lb-fadc-internal-be-pool-01" = {
      name                = "lb-fadc-internal-be-pool-01"
      resource_group_name = var.resource_group_name
      loadbalancer_id     = azurerm_lb.lb["lb-fadc-internal"].id
    }
  }

  lb_probes = {
    "lb-fadc-internal-probe" = {
      name                = "lb-fadc-internal-probe"
      resource_group_name = var.resource_group_name
      loadbalancer_id     = azurerm_lb.lb["lb-fadc-internal"].id
      port                = "8008"
      protocol            = "Tcp"
      interval_in_seconds = "5"
    }
  }

  lb_rules = {
    "lb-fadc-internal-rule-all" = {
      name                           = "lb-adc-internal-rule-all"
      resource_group_name            = var.resource_group_name
      loadbalancer_id                = azurerm_lb.lb["lb-fadc-internal"].id
      protocol                       = "All"
      frontend_port                  = 0
      backend_port                   = 0
      frontend_ip_configuration_name = "lb-fadc-internal-fe-ip-01"
      probe_id                       = azurerm_lb_probe.lb_probe["lb-fadc-internal-probe"].id
      backend_address_pool_id        = azurerm_lb_backend_address_pool.lb_backend_address_pool["lb-fadc-internal-be-pool-01"].id
      enable_floating_ip             = true
      disable_outbound_snat          = true
    }
  }

  network_interface_backend_address_pool_associations = {
    "nic-fortiadc_a_1" = {
      network_interface_id    = azurerm_network_interface.network_interface["nic-fortiadc_a_1"].id
      ip_configuration_name   = "ipconfig1"
      backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool["lb-fadc-internal-be-pool-01"].id
    },
    "nic-fortiadc_b_1" = {
      network_interface_id    = azurerm_network_interface.network_interface["nic-fortiadc_b_1"].id
      ip_configuration_name   = "ipconfig1"
      backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool["lb-fadc-internal-be-pool-01"].id
    }
  }

  availability_sets = {
    "as-fortiadc" = {
      name                = "as-fortiadc"
      location            = var.az_region
      resource_group_name = var.resource_group_name
    }
  }
  vm_configs = {
    "vm-fadc-a" = {
      name                = "vm-fadc-a"
      location            = var.az_region
      resource_group_name = var.resource_group_name

      config_template = "fadc-config.conf"
      identity        = "SystemAssigned"

      network_interface_ids        = [for nic in ["nic-fortiadc_a_1", "nic-fortiadc_a_2", "nic-fortiadc_a_3"] : azurerm_network_interface.network_interface[nic].id]
      primary_network_interface_id = azurerm_network_interface.network_interface["nic-fortiadc_a_1"].id

      publisher = var.vm_publisher
      offer     = var.vm_offer
      plan      = var.vm_sku
      version   = var.vm_version
      vm_size   = var.vm_size

      delete_os_disk_on_termination    = true
      delete_data_disks_on_termination = true


      storage_os_disk_name              = "disk-fadc-a-os"
      storage_os_disk_managed_disk_type = "Premium_LRS"
      storage_os_disk_create_option     = "FromImage"
      storage_os_disk_caching           = "ReadWrite"

      storage_data_disk_name              = "disk-vm-fadc-a-data"
      storage_data_disk_managed_disk_type = "Premium_LRS"
      storage_data_disk_create_option     = "Empty"
      storage_data_disk_disk_size_gb      = "30"
      storage_data_disk_lun               = "0"

      os_profile_computer_name  = "vm-fadc-a"
      os_profile_admin_username = var.vm_username
      os_profile_admin_password = var.vm_password

      zone = "1"

      availability_set_id = azurerm_availability_set.availability_set["as-fortiadc"].id


      fadc_license_file = "${var.fortinet_licenses["license_a"]}"
      fadc_config_ha     = true
      fadc_port1_ip      = cidrhost(var.snet_address_ranges["shared-services"], 8)
      fadc_port1_mask    = cidrnetmask(var.snet_address_ranges["shared-services"])
      fadc_port1_gateway = cidrhost(var.snet_address_ranges["shared-services"], 1)
      fadc_port2_ip      = cidrhost(var.snet_address_ranges["hasync"], 8)
      fadc_port2_mask    = cidrnetmask(var.snet_address_ranges["hasync"])
      fadc_port3_ip      = cidrhost(var.snet_address_ranges["fortinet-mgmt"], 8)
      fadc_port3_mask    = cidrnetmask(var.snet_address_ranges["fortinet-mgmt"])
      fadc_ha_localip    = cidrhost(var.snet_address_ranges["hasync"], 8)
      fadc_ha_peerip     = cidrhost(var.snet_address_ranges["hasync"], 9)
      fadc_ha_nodeid     = "5"
      fadc_a_ha_nodeid   = "0"
      fadc_b_ha_nodeid   = "1"
      fadc_ha_nodeid     = "0"
    },
    "vm-fadc-b" = {
      name                = "vm-fadc-b"
      location            = var.az_region
      resource_group_name = var.resource_group_name

      config_template = "fadc-config.conf"
      identity        = "SystemAssigned"

      network_interface_ids        = [for nic in ["nic-fortiadc_b_1", "nic-fortiadc_b_2", "nic-fortiadc_b_3"] : azurerm_network_interface.network_interface[nic].id]
      primary_network_interface_id = azurerm_network_interface.network_interface["nic-fortiadc_b_1"].id

      publisher = var.vm_publisher
      offer     = var.vm_offer
      plan      = var.vm_sku
      version   = var.vm_version
      vm_size   = var.vm_size

      delete_os_disk_on_termination    = true
      delete_data_disks_on_termination = true

      storage_os_disk_name              = "disk-fadc-b-os"
      storage_os_disk_managed_disk_type = "Premium_LRS"
      storage_os_disk_create_option     = "FromImage"
      storage_os_disk_caching           = "ReadWrite"

      storage_data_disk_name              = "disk-vm-fadc-b-data"
      storage_data_disk_managed_disk_type = "Premium_LRS"
      storage_data_disk_create_option     = "Empty"
      storage_data_disk_disk_size_gb      = "30"
      storage_data_disk_lun               = "0"

      os_profile_computer_name  = "vm-fadc-b"
      os_profile_admin_username = var.vm_username
      os_profile_admin_password = var.vm_password

      zone = "1"

      availability_set_id = azurerm_availability_set.availability_set["as-fortiadc"].id

      fadc_license_file  = "${var.fortinet_licenses["license_b"]}"
      fadc_config_ha     = true
      fadc_port1_ip      = cidrhost(var.snet_address_ranges["shared-services"], 9)
      fadc_port1_mask    = cidrnetmask(var.snet_address_ranges["shared-services"])
      fadc_port1_gateway = cidrhost(var.snet_address_ranges["shared-services"], 1)
      fadc_port2_ip      = cidrhost(var.snet_address_ranges["hasync"], 9)
      fadc_port2_mask    = cidrnetmask(var.snet_address_ranges["hasync"])
      fadc_port3_ip      = cidrhost(var.snet_address_ranges["fortinet-mgmt"], 9)
      fadc_port3_mask    = cidrnetmask(var.snet_address_ranges["fortinet-mgmt"])
      fadc_ha_localip    = cidrhost(var.snet_address_ranges["hasync"], 9)
      fadc_ha_peerip     = cidrhost(var.snet_address_ranges["hasync"], 8)
      fadc_ha_nodeid     = "9"
      fadc_a_ha_nodeid   = "0"
      fadc_b_ha_nodeid   = "1"
      fadc_ha_nodeid     = "1"
    }
  }
}

resource "azurerm_network_interface" "network_interface" {
  for_each = local.network_interfaces

  name                          = each.value.name
  location                      = each.value.location
  resource_group_name           = each.value.resource_group_name
  enable_ip_forwarding          = each.value.enable_ip_forwarding
  enable_accelerated_networking = each.value.enable_accelerated_networking

  ip_configuration {
    name                          = each.value.ip_configuration_name
    subnet_id                     = each.value.ip_configuration_subnet_id
    private_ip_address_allocation = each.value.ip_configuration_private_ip_address_allocation
    private_ip_address            = each.value.ip_configuration_private_ip_address
    public_ip_address_id          = each.value.ip_configuration_public_ip_address_id
  }
}

resource "azurerm_lb" "lb" {

  for_each = local.lbs

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  sku                 = each.value.sku

  frontend_ip_configuration {
    name                       = each.value.frontend_ip_configuration_name
    subnet_id                  = each.value.frontend_ip_configuration_subnet_id
    private_ip_address_version = each.value.frontend_ip_configuration_private_ip_address_version
    public_ip_address_id       = each.value.frontend_ip_configuration_public_ip_address_id
  }
}

resource "azurerm_lb_backend_address_pool" "lb_backend_address_pool" {

  for_each = local.lb_backend_address_pools

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  loadbalancer_id     = each.value.loadbalancer_id
}

resource "azurerm_lb_probe" "lb_probe" {

  for_each = local.lb_probes

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  loadbalancer_id     = each.value.loadbalancer_id
  port                = each.value.port
  protocol            = each.value.protocol
  interval_in_seconds = each.value.interval_in_seconds
}

resource "azurerm_lb_rule" "lb_rule" {

  for_each = local.lb_rules

  name                           = each.value.name
  resource_group_name            = each.value.resource_group_name
  loadbalancer_id                = each.value.loadbalancer_id
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  probe_id                       = each.value.probe_id
  backend_address_pool_id        = each.value.backend_address_pool_id
  enable_floating_ip             = each.value.enable_floating_ip
  disable_outbound_snat          = each.value.disable_outbound_snat
}

resource "azurerm_network_interface_backend_address_pool_association" "network_interface_backend_address_pool_association" {

  for_each = local.network_interface_backend_address_pool_associations

  network_interface_id    = each.value.network_interface_id
  ip_configuration_name   = each.value.ip_configuration_name
  backend_address_pool_id = each.value.backend_address_pool_id

  depends_on = [
    azurerm_network_interface.network_interface,
    azurerm_virtual_machine.virtual_machine
  ]
}

resource "azurerm_availability_set" "availability_set" {

  for_each = local.availability_sets

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
}

resource "azurerm_virtual_machine" "virtual_machine" {
  for_each = local.vm_configs

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  network_interface_ids        = each.value.network_interface_ids
  primary_network_interface_id = each.value.primary_network_interface_id
  vm_size                      = each.value.vm_size

  delete_os_disk_on_termination    = each.value.delete_os_disk_on_termination
  delete_data_disks_on_termination = each.value.delete_data_disks_on_termination

  boot_diagnostics {
    enabled     = true
    storage_uri = var.storage_account
  }

  identity {
    type = each.value.identity
  }

  storage_image_reference {
    publisher = each.value.publisher
    offer     = each.value.offer
    sku       = each.value.plan
    version   = each.value.version
  }

  plan {
    publisher = each.value.publisher
    product   = each.value.offer
    name      = each.value.plan
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
    computer_name  = each.value.os_profile_computer_name
    admin_username = each.value.os_profile_admin_username
    admin_password = each.value.os_profile_admin_password
    custom_data    = data.template_file.custom_data[each.key].rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  #zones = [each.value.zone]

  availability_set_id = each.value.availability_set_id

  depends_on = [
    azurerm_network_interface.network_interface
  ]
}

data "template_file" "custom_data" {
  for_each = local.vm_configs
  template = file("${path.module}/${each.value.config_template}")
  vars = {
    fadc_id            = each.value.name
    fadc_license_file  = each.value.fadc_license_file
    fadc_config_ha     = true
    fadc_port1_ip      = each.value.fadc_port1_ip
    fadc_port1_mask    = each.value.fadc_port1_mask
    fadc_port1_gateway = each.value.fadc_port1_gateway
    fadc_port2_ip      = each.value.fadc_port2_ip
    fadc_port2_mask    = each.value.fadc_port2_mask
    fadc_port3_ip      = each.value.fadc_port3_ip
    fadc_port3_mask    = each.value.fadc_port3_mask
    fadc_ha_localip    = each.value.fadc_ha_localip
    fadc_ha_peerip     = each.value.fadc_ha_peerip
    fadc_ha_priority   = each.value.fadc_ha_nodeid
    fadc_a_ha_nodeid   = each.value.fadc_a_ha_nodeid
    fadc_b_ha_nodeid   = each.value.fadc_b_ha_nodeid
    fadc_ha_nodeid     = each.value.fadc_ha_nodeid
  }
}
