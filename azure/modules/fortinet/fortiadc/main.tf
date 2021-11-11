locals {

  fadc-license_a-basename = trimprefix(var.fortinet_licenses["license_a"], "./")
  fadc-license_b-basename = trimprefix(var.fortinet_licenses["license_b"], "./")

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

  storage_accounts = {
    "sa-fortinet" = {
      name                     = format("%s%s", "safadc", "${var.random_id}")
      location                 = var.az_region
      resource_group_name      = var.resource_group_name
      account_tier             = "Standard"
      account_replication_type = "LRS"
      allow_blob_public_access = true
    } 
  }

  storage_containers = {
    "sc-fadc" = {
      name                  = "sc-fadc"
      storage_account_name  = azurerm_storage_account.storage_account["sa-fortinet"].name
      container_access_type = "blob"
    }
  }

  storage_blobs = {
    "sb-fadc-license-a" = {
      name                   = var.fortinet_licenses["license_a"]
      storage_account_name   = azurerm_storage_account.storage_account["sa-fortinet"].name
      storage_container_name = azurerm_storage_container.storage_container["sc-fadc"].name
      type                   = "Block"
      source                 = "${var.fortinet_licenses["license_a"]}"
    },
    "sb-fadc-license-b" = {
      name                   = var.fortinet_licenses["license_b"] 
      storage_account_name   = azurerm_storage_account.storage_account["sa-fortinet"].name
      storage_container_name = azurerm_storage_container.storage_container["sc-fadc"].name
      type                   = "Block"
      source                 = "${var.fortinet_licenses["license_b"]}"
    },
    "sb-fadc-config-a" = {
      name                   = "fadc-config-a.txt"
      storage_account_name   = azurerm_storage_account.storage_account["sa-fortinet"].name
      storage_container_name = azurerm_storage_container.storage_container["sc-fadc"].name
      type                   = "Block"
      source                 = "${path.module}/fadc-config-a.txt"
    },
    "sb-fadc-config-b" = {
      name                   = "fadc-config-b.txt"
      storage_account_name   = azurerm_storage_account.storage_account["sa-fortinet"].name
      storage_container_name = azurerm_storage_container.storage_container["sc-fadc"].name
      type                   = "Block"
      source                 = "${path.module}/fadc-config-b.txt"
    }
  }
  lbs = {
    "lb-fadc-internal" = {
      name                                                 = "lb-fadc-internal"
      location                                             = var.az_region
      resource_group_name                                  = var.resource_group_name
      sku                                                  = "standard"

      frontend_ip_configurations = [
        {
          name                          = "lb-fadc-internal-fe-ip-01"
          subnet_id                     = var.snet_ids["shared-services"]
          private_ip_address            = cidrhost(var.snet_address_ranges["shared-services"], 4)
          private_ip_address_allocation = "Static"
          private_ip_address_version    = "IPv4"
        }
      ]
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
      os_profile_custom_data    = base64encode(local.fadc_configs["fadc-cloudinit-a"].config)

      zone = "1"

      availability_set_id = azurerm_availability_set.availability_set["as-fortiadc"].id


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
      os_profile_custom_data    = base64encode(local.fadc_configs["fadc-cloudinit-b"].config)

      zone = "1"

      availability_set_id = azurerm_availability_set.availability_set["as-fortiadc"].id
    }
  }
  fadc_configs = {
    "fadc-config-a" = {
      
      name = "fadc-config-a"
      config = <<FADCCONFIG
        config system global
          set hostname vm-fadc-a
          set admin-idle-timeout 120
        end
        FADCCONFIG
    },
    "fadc-config-b" = {
      
      name = "fadc-config-b"
      config = <<FADCCONFIG
        config system global
          set hostname vm-fadc-b
          set admin-idle-timeout 120
        end
        FADCCONFIG
    },
    "fadc-cloudinit-a" = {
      name = "fadc-cloudinit-a"
      config = <<CLOUDINIT
        {
          "storage-account" : "${azurerm_storage_account.storage_account["sa-fortinet"].name}",
          "container" : "${azurerm_storage_container.storage_container["sc-fadc"].name}",
          "license" : "${local.fadc-license_a-basename}",
          "config" : "fadc-config-a.txt"
        }
      CLOUDINIT
    },
      "fadc-cloudinit-b" = {
      name = "fadc-cloudinit-b"
      config = <<CLOUDINIT
        {
          "storage-account" : "${azurerm_storage_account.storage_account["sa-fortinet"].name}",
          "container" : "${azurerm_storage_container.storage_container["sc-fadc"].name}",
          "license" : "${local.fadc-license_a-basename}",
          "config" : "fadc-config-b.txt"
        }
      CLOUDINIT
    }
  }
}

resource "local_file" "file" {

  for_each = local.fadc_configs

  filename = "${path.module}/${each.value.name}.txt"
  content  = each.value.config
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

resource "azurerm_storage_account" "storage_account" {

  for_each = local.storage_accounts

  name                     = each.value.name
  location                 = each.value.location
  resource_group_name      = each.value.resource_group_name
  account_tier             = each.value.account_tier
  account_replication_type = each.value.account_replication_type
  allow_blob_public_access = each.value.allow_blob_public_access
}

resource "azurerm_storage_container" "storage_container" {

  for_each = local.storage_containers

  name                  = each.value.name
  storage_account_name  = each.value.storage_account_name
  container_access_type = each.value.container_access_type
}

resource "azurerm_storage_blob" "storage_blob" {

  for_each = local.storage_blobs

  name                   = each.value.name                  
  storage_account_name   = each.value.storage_account_name  
  storage_container_name = each.value.storage_container_name
  type                   = each.value.type                  
  source                 = each.value.source                
}

resource "azurerm_lb" "lb" {

  for_each = local.lbs

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  sku                 = each.value.sku

  dynamic "frontend_ip_configuration" {
    for_each = [
      for fe_ip in each.value.frontend_ip_configurations : fe_ip
      if lookup(fe_ip, "public_ip_address_id", null) != null
    ]
    content {
      name                          = frontend_ip_configuration.value.name
      public_ip_address_id          = frontend_ip_configuration.value.public_ip_address_id
    }
  }
  dynamic "frontend_ip_configuration" {
    for_each = [
      for fe_ip in each.value.frontend_ip_configurations : fe_ip
      if lookup(fe_ip, "private_ip_address", null) != null
    ]
    content {
      name                          = frontend_ip_configuration.value.name
      subnet_id                     = frontend_ip_configuration.value.subnet_id
      private_ip_address            = frontend_ip_configuration.value.private_ip_address
      private_ip_address_allocation = frontend_ip_configuration.value.private_ip_address_allocation
      private_ip_address_version    = frontend_ip_configuration.value.private_ip_address_version
    }
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
    custom_data    = each.value.os_profile_custom_data
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
