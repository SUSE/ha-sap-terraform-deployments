# Availability set for the hana VMs

resource "azurerm_availability_set" "hana-availability-set" {
  name                        = "avset-hana"
  location                    = var.az_region
  resource_group_name         = var.resource_group_name
  managed                     = "true"
  platform_fault_domain_count = 2

  tags = {
    workspace = terraform.workspace
  }
}

# hana load balancer items

resource "azurerm_lb" "hana-load-balancer" {
  name                = "lb-hana"
  location            = var.az_region
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                          = "lbfe-hana"
    subnet_id                     = var.network_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = var.hana_cluster_vip
  }

  tags = {
    workspace = terraform.workspace
  }
}

# backend pools

resource "azurerm_lb_backend_address_pool" "hana-load-balancer" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.hana-load-balancer.id
  name                = "lbbe-hana"
}

resource "azurerm_network_interface_backend_address_pool_association" "hana" {
  count                   = var.hana_count
  network_interface_id    = element(azurerm_network_interface.hana.*.id, count.index)
  ip_configuration_name   = "ipconf-primary"
  backend_address_pool_id = azurerm_lb_backend_address_pool.hana-load-balancer.id
}

resource "azurerm_lb_probe" "hana-load-balancer" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.hana-load-balancer.id
  name                = "lbhp-hana"
  protocol            = "Tcp"
  port                = tonumber("625${var.hana_instance_number}")
  interval_in_seconds = 5
  number_of_probes    = 2
}

# Load balancing rules for HANA 2.0
resource "azurerm_lb_rule" "lb_3xx13" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.hana-load-balancer.id
  name                           = "lbrule-hana-tcp-3${var.hana_instance_number}13"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "lbfe-hana"
  frontend_port                  = tonumber("3${var.hana_instance_number}13")
  backend_port                   = tonumber("3${var.hana_instance_number}13")
  backend_address_pool_id        = azurerm_lb_backend_address_pool.hana-load-balancer.id
  probe_id                       = azurerm_lb_probe.hana-load-balancer.id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

resource "azurerm_lb_rule" "lb_3xx14" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.hana-load-balancer.id
  name                           = "lbrule-hana-tcp-3${var.hana_instance_number}14"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "lbfe-hana"
  frontend_port                  = tonumber("3${var.hana_instance_number}14")
  backend_port                   = tonumber("3${var.hana_instance_number}14")
  backend_address_pool_id        = azurerm_lb_backend_address_pool.hana-load-balancer.id
  probe_id                       = azurerm_lb_probe.hana-load-balancer.id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

resource "azurerm_lb_rule" "lb_3xx40" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.hana-load-balancer.id
  name                           = "lbrule-hana-tcp-3${var.hana_instance_number}40"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "lbfe-hana"
  frontend_port                  = tonumber("3${var.hana_instance_number}40")
  backend_port                   = tonumber("3${var.hana_instance_number}40")
  backend_address_pool_id        = azurerm_lb_backend_address_pool.hana-load-balancer.id
  probe_id                       = azurerm_lb_probe.hana-load-balancer.id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

resource "azurerm_lb_rule" "lb_3xx41" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.hana-load-balancer.id
  name                           = "lbrule-hana-tcp-3${var.hana_instance_number}41"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "lbfe-hana"
  frontend_port                  = tonumber("3${var.hana_instance_number}41")
  backend_port                   = tonumber("3${var.hana_instance_number}41")
  backend_address_pool_id        = azurerm_lb_backend_address_pool.hana-load-balancer.id
  probe_id                       = azurerm_lb_probe.hana-load-balancer.id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

resource "azurerm_lb_rule" "lb_3xx42" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.hana-load-balancer.id
  name                           = "lbrule-hana-tcp-3${var.hana_instance_number}42"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "lbfe-hana"
  frontend_port                  = tonumber("3${var.hana_instance_number}42")
  backend_port                   = tonumber("3${var.hana_instance_number}42")
  backend_address_pool_id        = azurerm_lb_backend_address_pool.hana-load-balancer.id
  probe_id                       = azurerm_lb_probe.hana-load-balancer.id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}


# Load balancing rules for HANA 1.0
resource "azurerm_lb_rule" "lb_3xx15" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.hana-load-balancer.id
  name                           = "lbrule-hana-tcp-3${var.hana_instance_number}15"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "lbfe-hana"
  frontend_port                  = tonumber("3${var.hana_instance_number}15")
  backend_port                   = tonumber("3${var.hana_instance_number}15")
  backend_address_pool_id        = azurerm_lb_backend_address_pool.hana-load-balancer.id
  probe_id                       = azurerm_lb_probe.hana-load-balancer.id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

resource "azurerm_lb_rule" "lb_3xx17" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.hana-load-balancer.id
  name                           = "lbrule-hana-tcp-3${var.hana_instance_number}17"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "lbfe-hana"
  frontend_port                  = tonumber("3${var.hana_instance_number}17")
  backend_port                   = tonumber("3${var.hana_instance_number}17")
  backend_address_pool_id        = azurerm_lb_backend_address_pool.hana-load-balancer.id
  probe_id                       = azurerm_lb_probe.hana-load-balancer.id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

# hana network configuration

resource "azurerm_network_interface" "hana" {
  count                         = var.hana_count
  name                          = "nic-${var.name}0${count.index + 1}"
  location                      = var.az_region
  resource_group_name           = var.resource_group_name
  network_security_group_id     = var.sec_group_id
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "ipconf-primary"
    subnet_id                     = var.network_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = element(var.host_ips, count.index)
    public_ip_address_id          = element(azurerm_public_ip.hana.*.id, count.index)
  }

  tags = {
    workspace = terraform.workspace
  }
}

resource "azurerm_public_ip" "hana" {
  count                   = var.hana_count
  name                    = "pip-${var.name}0${count.index + 1}"
  location                = var.az_region
  resource_group_name     = var.resource_group_name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    workspace = terraform.workspace
  }
}

resource "azurerm_image" "sles4sap" {
  count               = var.sles4sap_uri != "" ? 1 : 0
  name                = "BVSles4SapImg"
  location            = var.az_region
  resource_group_name = var.resource_group_name

  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = var.sles4sap_uri
    size_gb  = "32"
  }

  tags = {
    workspace = terraform.workspace
  }
}

# hana instances

resource "azurerm_virtual_machine" "hana" {
  count                            = var.hana_count
  name                             = "vm${var.name}0${count.index + 1}"
  location                         = var.az_region
  resource_group_name              = var.resource_group_name
  network_interface_ids            = [element(azurerm_network_interface.hana.*.id, count.index)]
  availability_set_id              = azurerm_availability_set.hana-availability-set.id
  vm_size                          = var.vm_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = "disk-${var.name}0${count.index + 1}-Os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    id        = var.sles4sap_uri != "" ? join(",", azurerm_image.sles4sap.*.id) : ""
    publisher = var.sles4sap_uri != "" ? "" : var.hana_public_publisher
    offer     = var.sles4sap_uri != "" ? "" : var.hana_public_offer
    sku       = var.sles4sap_uri != "" ? "" : var.hana_public_sku
    version   = var.sles4sap_uri != "" ? "" : var.hana_public_version
  }

  storage_data_disk {
    name              = "disk-${var.name}0${count.index + 1}-Data01"
    managed_disk_type = var.hana_data_disk_type
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = var.hana_data_disk_size
    caching           = var.hana_data_disk_caching
  }

  storage_data_disk {
    name              = "disk-${var.name}0${count.index + 1}-Data02"
    managed_disk_type = var.hana_data_disk_type
    create_option     = "Empty"
    lun               = 1
    disk_size_gb      = var.hana_data_disk_size
    caching           = var.hana_data_disk_caching
  }

  storage_data_disk {
    name              = "disk-${var.name}0${count.index + 1}-Data03"
    managed_disk_type = var.hana_data_disk_type
    create_option     = "Empty"
    lun               = 2
    disk_size_gb      = var.hana_data_disk_size
    caching           = var.hana_data_disk_caching
  }

  os_profile {
    computer_name  = "vm${var.name}0${count.index + 1}"
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

module "hana_on_destroy" {
  source               = "../../../generic_modules/on_destroy"
  node_count           = var.hana_count
  instance_ids         = azurerm_virtual_machine.hana.*.id
  user                 = var.admin_user
  private_key_location = var.private_key_location
  public_ips           = data.azurerm_public_ip.hana.*.ip_address
  dependencies         = [data.azurerm_public_ip.hana]
}
