# netweaver deployment in Azure
# official documentation: https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/high-availability-guide-suse

resource "azurerm_availability_set" "netweaver-availability-set" {
  count                       = var.netweaver_count > 0 ? 1 : 0
  name                        = "avset-netweaver"
  location                    = var.az_region
  resource_group_name         = var.resource_group_name
  managed                     = "true"
  platform_fault_domain_count = 2

  tags = {
    workspace = terraform.workspace
  }
}

# netweaver load balancer items

resource "azurerm_lb" "netweaver-load-balancer" {
  count               = var.netweaver_count > 0 ? 1 : 0
  name                = "lb-netweaver"
  location            = var.az_region
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                          = "lbfe-netweaver-ascs"
    subnet_id                     = var.network_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = element(var.virtual_host_ips, 0)
  }

  frontend_ip_configuration {
    name                          = "lbfe-netweaver-ers"
    subnet_id                     = var.network_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = element(var.virtual_host_ips, 1)
  }

  frontend_ip_configuration {
    name                          = "lbfe-netweaver-pas"
    subnet_id                     = var.network_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = element(var.virtual_host_ips, 2)
  }

  frontend_ip_configuration {
    name                          = "lbfe-netweaver-aas"
    subnet_id                     = var.network_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = element(var.virtual_host_ips, 3)
  }

  tags = {
    workspace = terraform.workspace
  }
}

# backend pools

resource "azurerm_lb_backend_address_pool" "netweaver-backend-pool" {
  count               = var.netweaver_count > 0 ? 1 : 0
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.netweaver-load-balancer[0].id
  name                = "lbbe-netweaver"
}

resource "azurerm_network_interface_backend_address_pool_association" "netweaver-nodes" {
  count                   = var.netweaver_count
  network_interface_id    = element(azurerm_network_interface.netweaver.*.id, count.index)
  ip_configuration_name   = "ipconf-primary"
  backend_address_pool_id = azurerm_lb_backend_address_pool.netweaver-backend-pool[0].id
}

# health probes
# example: Instance number: 00, port: 62000, Instance number: 01, port: 62001

resource "azurerm_lb_probe" "netweaver-ascs-health-probe" {
  count               = var.netweaver_count > 0 ? 1 : 0
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.netweaver-load-balancer[0].id
  name                = "lbhp-netweaver-ascs"
  protocol            = "Tcp"
  port                = tonumber("620${var.ascs_instance_number}")
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_probe" "netweaver-ers-health-probe" {
  count               = var.netweaver_count > 0 ? 1 : 0
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.netweaver-load-balancer[0].id
  name                = "lbhp-netweaver-ers"
  protocol            = "Tcp"
  port                = tonumber("621${var.ers_instance_number}")
  interval_in_seconds = 5
  number_of_probes    = 2
}

# load balancing rules. The ports must use the Netweaver instance number in their composition
# example: Instance number: 00, port: 3200, Instance number: 01, port: 3201

# Only for Standard load balancer, which requires other more expensive registration
#resource "azurerm_lb_rule" "netweaver-lb-ha-ascs" {
#  count                          = var.netweaver_count > 0 ? 1 : 0
#  resource_group_name            = var.resource_group_name
#  loadbalancer_id                = azurerm_lb.netweaver-load-balancer.id
#  name                           = "lbrule-netweaver-ascs-all"
#  protocol                       = "All"
#  frontend_ip_configuration_name = "lbfe-netweaver-ascs"
#  frontend_port                  = 0
#  backend_port                   = 0
#  backend_address_pool_id        = azurerm_lb_backend_address_pool.netweaver-backend-pool[0].id
#  probe_id                       = azurerm_lb_probe.netweaver-health-probe[0].id
#  idle_timeout_in_minutes        = 30
#  enable_floating_ip             = "true"
#}

#resource "azurerm_lb_rule" "netweaver-lb-ha-ers" {
#  count                          = var.netweaver_count > 0 ? 1 : 0
#  resource_group_name            = var.resource_group_name
#  loadbalancer_id                = azurerm_lb.netweaver-load-balancer.id
#  name                           = "lbrule-netweaver-ers-all"
#  protocol                       = "All"
#  frontend_ip_configuration_name = "lbfe-netweaver-ers"
#  frontend_port                  = 0
#  backend_port                   = 0
#  backend_address_pool_id        = azurerm_lb_backend_address_pool.netweaver-backend-pool[1].id
#  probe_id                       = azurerm_lb_probe.netweaver-health-probe[1].id
#  idle_timeout_in_minutes        = 30
#  enable_floating_ip             = "true"
#}

# ascs

resource "azurerm_lb_rule" "netweaver-lb-ascs-32xx" {
  count                          = var.netweaver_count > 0 ? 1 : 0
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.netweaver-load-balancer[0].id
  name                           = "lbrule-neweaver-ascs-tcp-32${var.ascs_instance_number}"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "lbfe-netweaver-ascs"
  frontend_port                  = tonumber("32${var.ascs_instance_number}")
  backend_port                   = tonumber("32${var.ascs_instance_number}")
  backend_address_pool_id        = azurerm_lb_backend_address_pool.netweaver-backend-pool[0].id
  probe_id                       = azurerm_lb_probe.netweaver-ascs-health-probe[0].id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

resource "azurerm_lb_rule" "netweaver-lb-ascs-36xx" {
  count                          = var.netweaver_count > 0 ? 1 : 0
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.netweaver-load-balancer[0].id
  name                           = "lbrule-neweaver-ascs-tcp-36${var.ascs_instance_number}"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "lbfe-netweaver-ascs"
  frontend_port                  = tonumber("36${var.ascs_instance_number}")
  backend_port                   = tonumber("36${var.ascs_instance_number}")
  backend_address_pool_id        = azurerm_lb_backend_address_pool.netweaver-backend-pool[0].id
  probe_id                       = azurerm_lb_probe.netweaver-ascs-health-probe[0].id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

resource "azurerm_lb_rule" "netweaver-lb-ascs-39xx" {
  count                          = var.netweaver_count > 0 ? 1 : 0
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.netweaver-load-balancer[0].id
  name                           = "lbrule-neweaver-ascs-tcp-39${var.ascs_instance_number}"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "lbfe-netweaver-ascs"
  frontend_port                  = tonumber("39${var.ascs_instance_number}")
  backend_port                   = tonumber("39${var.ascs_instance_number}")
  backend_address_pool_id        = azurerm_lb_backend_address_pool.netweaver-backend-pool[0].id
  probe_id                       = azurerm_lb_probe.netweaver-ascs-health-probe[0].id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

resource "azurerm_lb_rule" "netweaver-lb-ascs-81xx" {
  count                          = var.netweaver_count > 0 ? 1 : 0
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.netweaver-load-balancer[0].id
  name                           = "lbrule-neweaver-ascs-tcp-81${var.ascs_instance_number}"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "lbfe-netweaver-ascs"
  frontend_port                  = tonumber("81${var.ascs_instance_number}")
  backend_port                   = tonumber("81${var.ascs_instance_number}")
  backend_address_pool_id        = azurerm_lb_backend_address_pool.netweaver-backend-pool[0].id
  probe_id                       = azurerm_lb_probe.netweaver-ascs-health-probe[0].id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

resource "azurerm_lb_rule" "netweaver-lb-ascs-5xx13" {
  count                          = var.netweaver_count > 0 ? 1 : 0
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.netweaver-load-balancer[0].id
  name                           = "lbrule-neweaver-ascs-tcp-5${var.ascs_instance_number}13"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "lbfe-netweaver-ascs"
  frontend_port                  = tonumber("5${var.ascs_instance_number}13")
  backend_port                   = tonumber("5${var.ascs_instance_number}13")
  backend_address_pool_id        = azurerm_lb_backend_address_pool.netweaver-backend-pool[0].id
  probe_id                       = azurerm_lb_probe.netweaver-ascs-health-probe[0].id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

resource "azurerm_lb_rule" "netweaver-lb-ascs-5xx14" {
  count                          = var.netweaver_count > 0 ? 1 : 0
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.netweaver-load-balancer[0].id
  name                           = "lbrule-neweaver-ascs-tcp-5${var.ascs_instance_number}14"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "lbfe-netweaver-ascs"
  frontend_port                  = tonumber("5${var.ascs_instance_number}14")
  backend_port                   = tonumber("5${var.ascs_instance_number}14")
  backend_address_pool_id        = azurerm_lb_backend_address_pool.netweaver-backend-pool[0].id
  probe_id                       = azurerm_lb_probe.netweaver-ascs-health-probe[0].id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

resource "azurerm_lb_rule" "netweaver-lb-ascs-5xx16" {
  count                          = var.netweaver_count > 0 ? 1 : 0
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.netweaver-load-balancer[0].id
  name                           = "lbrule-neweaver-ascs-tcp-5${var.ascs_instance_number}16"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "lbfe-netweaver-ascs"
  frontend_port                  = tonumber("5${var.ascs_instance_number}16")
  backend_port                   = tonumber("5${var.ascs_instance_number}16")
  backend_address_pool_id        = azurerm_lb_backend_address_pool.netweaver-backend-pool[0].id
  probe_id                       = azurerm_lb_probe.netweaver-ascs-health-probe[0].id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

# ers

resource "azurerm_lb_rule" "netweaver-lb-ers-32xx" {
  count                          = var.netweaver_count > 0 ? 1 : 0
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.netweaver-load-balancer[0].id
  name                           = "lbrule-netweaver-ers-tcp-32${var.ers_instance_number}"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "lbfe-netweaver-ers"
  frontend_port                  = tonumber("32${var.ers_instance_number}")
  backend_port                   = tonumber("32${var.ers_instance_number}")
  backend_address_pool_id        = azurerm_lb_backend_address_pool.netweaver-backend-pool[0].id
  probe_id                       = azurerm_lb_probe.netweaver-ers-health-probe[0].id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

resource "azurerm_lb_rule" "netweaver-lb-ers-33xx" {
  count                          = var.netweaver_count > 0 ? 1 : 0
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.netweaver-load-balancer[0].id
  name                           = "lbrule-netweaver-ers-tcp-33${var.ers_instance_number}"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "lbfe-netweaver-ers"
  frontend_port                  = tonumber("33${var.ers_instance_number}")
  backend_port                   = tonumber("33${var.ers_instance_number}")
  backend_address_pool_id        = azurerm_lb_backend_address_pool.netweaver-backend-pool[0].id
  probe_id                       = azurerm_lb_probe.netweaver-ers-health-probe[0].id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

resource "azurerm_lb_rule" "netweaver-lb-ers-5xx13" {
  count                          = var.netweaver_count > 0 ? 1 : 0
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.netweaver-load-balancer[0].id
  name                           = "lbrule-netweaver-ers-tcp-5${var.ers_instance_number}13"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "lbfe-netweaver-ers"
  frontend_port                  = tonumber("5${var.ers_instance_number}13")
  backend_port                   = tonumber("5${var.ers_instance_number}13")
  backend_address_pool_id        = azurerm_lb_backend_address_pool.netweaver-backend-pool[0].id
  probe_id                       = azurerm_lb_probe.netweaver-ers-health-probe[0].id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

resource "azurerm_lb_rule" "netweaver-lb-ers-5xx14" {
  count                          = var.netweaver_count > 0 ? 1 : 0
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.netweaver-load-balancer[0].id
  name                           = "lbrule-netweaver-ers-tcp-5${var.ers_instance_number}14"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "lbfe-netweaver-ers"
  frontend_port                  = tonumber("5${var.ers_instance_number}14")
  backend_port                   = tonumber("5${var.ers_instance_number}14")
  backend_address_pool_id        = azurerm_lb_backend_address_pool.netweaver-backend-pool[0].id
  probe_id                       = azurerm_lb_probe.netweaver-ers-health-probe[0].id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

resource "azurerm_lb_rule" "netweaver-lb-ers-5xx16" {
  count                          = var.netweaver_count > 0 ? 1 : 0
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.netweaver-load-balancer[0].id
  name                           = "lbrule-netweaver-ers-tcp-5${var.ers_instance_number}16"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "lbfe-netweaver-ers"
  frontend_port                  = tonumber("5${var.ers_instance_number}16")
  backend_port                   = tonumber("5${var.ers_instance_number}16")
  backend_address_pool_id        = azurerm_lb_backend_address_pool.netweaver-backend-pool[0].id
  probe_id                       = azurerm_lb_probe.netweaver-ers-health-probe[0].id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

# netweaver network configuration

resource "azurerm_public_ip" "netweaver" {
  count                   = var.netweaver_count
  name                    = "pip-netweaver0${count.index + 1}"
  location                = var.az_region
  resource_group_name     = var.resource_group_name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    workspace = terraform.workspace
  }
}

resource "azurerm_network_interface" "netweaver" {
  count                         = var.netweaver_count
  name                          = "nic-netweaver0${count.index + 1}"
  location                      = var.az_region
  resource_group_name           = var.resource_group_name
  network_security_group_id     = var.sec_group_id
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "ipconf-primary"
    subnet_id                     = var.network_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = element(var.host_ips, count.index)
    public_ip_address_id          = element(azurerm_public_ip.netweaver.*.id, count.index)
  }

  tags = {
    workspace = terraform.workspace
  }
}

# netweaver custom image. only available is netweaver_image_uri is used

resource "azurerm_image" "netweaver-image" {
  count               = var.netweaver_image_uri != "" ? 1 : 0
  name                = "img-netweaver"
  location            = var.az_region
  resource_group_name = var.resource_group_name

  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = var.netweaver_image_uri
    size_gb  = "32"
  }

  tags = {
    workspace = terraform.workspace
  }
}

# netweaver instances

resource "azurerm_virtual_machine" "netweaver" {
  count                            = var.netweaver_count
  name                             = "vmnetweaver0${count.index + 1}"
  location                         = var.az_region
  resource_group_name              = var.resource_group_name
  network_interface_ids            = [element(azurerm_network_interface.netweaver.*.id, count.index)]
  availability_set_id              = azurerm_availability_set.netweaver-availability-set[0].id
  vm_size                          = var.vm_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = "disk-netweaver0${count.index + 1}-Os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    id        = var.netweaver_image_uri != "" ? join(",", azurerm_image.netweaver-image.*.id) : ""
    publisher = var.netweaver_image_uri != "" ? "" : var.netweaver_public_publisher
    offer     = var.netweaver_image_uri != "" ? "" : var.netweaver_public_offer
    sku       = var.netweaver_image_uri != "" ? "" : var.netweaver_public_sku
    version   = var.netweaver_image_uri != "" ? "" : var.netweaver_public_version
  }

  storage_data_disk {
    name              = "disk-netweaver0${count.index + 1}-Data01"
    caching           = var.data_disk_caching
    create_option     = "Empty"
    disk_size_gb      = var.data_disk_size
    lun               = "0"
    managed_disk_type = var.data_disk_type
  }

  os_profile {
    computer_name  = "vmnetweaver0${count.index + 1}"
    admin_username = var.admin_user
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_user}/.ssh/authorized_keys"
      key_data = file(var.public_key_location)
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = var.storage_account
  }

  tags = {
    workspace = terraform.workspace
  }
}

module "netweaver_on_destroy" {
  source               = "../../../generic_modules/on_destroy"
  node_count           = var.netweaver_count
  instance_ids         = azurerm_virtual_machine.netweaver.*.id
  user                 = var.admin_user
  private_key_location = var.private_key_location
  public_ips           = data.azurerm_public_ip.netweaver.*.ip_address
  dependencies         = [data.azurerm_public_ip.netweaver]
}
