# drbd deployment in Azure to host a HA NFS share for SAP Netweaver
# official documentation: https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/high-availability-guide-suse-nfs
# disclaimer: only supports a single NW installation

# drbd load balancer

resource "azurerm_lb" "drbd-load-balancer" {
  count               = var.drbd_count > 0 ? 1 : 0
  name                = "drbd-load-balancer"
  location            = var.az_region
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                          = "drbd-frontend"
    subnet_id                     = var.network_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = "10.74.1.201"
  }

  tags = {
    workspace = terraform.workspace
  }
}

resource "azurerm_lb_backend_address_pool" "drbd-backend-pool" {
  count               = var.drbd_count > 0 ? 1 : 0
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.drbd-load-balancer[count.index].id
  name                = "drbd-backend-pool"
}

resource "azurerm_network_interface_backend_address_pool_association" "drbd-nodes" {
  count                   = var.drbd_count
  network_interface_id    = element(azurerm_network_interface.drbd.*.id, count.index)
  ip_configuration_name   = "drbd-ip-configuration-${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.drbd-backend-pool[0].id
}

resource "azurerm_lb_probe" "drbd-health-probe" {
  count               = var.drbd_count > 0 ? 1 : 0
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.drbd-load-balancer[count.index].id
  name                = "drbd-health-probe"
  protocol            = "Tcp"
  port                = 61000
  interval_in_seconds = 5
  number_of_probes    = 2
}

# Only for Standard load balancer, which requires other more expensive registration
#resource "azurerm_lb_rule" "drbd-lb-ha" {
#  count                          = var.drbd_count > 0 ? 1 : 0
#  resource_group_name            = var.resource_group_name
#  loadbalancer_id                = azurerm_lb.drbd-load-balancer.id
#  name                           = "drbd-lb-ha"
#  protocol                       = "All"
#  frontend_ip_configuration_name = "drbd-frontend"
#  frontend_port                  = 0
#  backend_port                   = 0
#  backend_address_pool_id        = azurerm_lb_backend_address_pool.drbd-backend-pool[0].id
#  probe_id                       = azurerm_lb_probe.drbd-health-probe.id
#  idle_timeout_in_minutes        = 30
#  enable_floating_ip             = "true"
#}

resource "azurerm_lb_rule" "drbd-lb-tcp-2049" {
  count                          = var.drbd_count > 0 ? 1 : 0
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.drbd-load-balancer[count.index].id
  name                           = "drbd-lb-tcp-2049"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "drbd-frontend"
  frontend_port                  = 2049
  backend_port                   = 2049
  backend_address_pool_id        = azurerm_lb_backend_address_pool.drbd-backend-pool[count.index].id
  probe_id                       = azurerm_lb_probe.drbd-health-probe[count.index].id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

resource "azurerm_lb_rule" "drbd-lb-udp-2049" {
  count                          = var.drbd_count > 0 ? 1 : 0
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.drbd-load-balancer[count.index].id
  name                           = "drbd-lb-udp-2049"
  protocol                       = "Udp"
  frontend_ip_configuration_name = "drbd-frontend"
  frontend_port                  = 2049
  backend_port                   = 2049
  backend_address_pool_id        = azurerm_lb_backend_address_pool.drbd-backend-pool[count.index].id
  probe_id                       = azurerm_lb_probe.drbd-health-probe[count.index].id
  idle_timeout_in_minutes        = 30
  enable_floating_ip             = "true"
}

# drbd network configuration

resource "azurerm_public_ip" "drbd" {
  count                   = var.drbd_count
  name                    = "drbd-ip-${count.index}"
  location                = var.az_region
  resource_group_name     = var.resource_group_name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    workspace = terraform.workspace
  }
}

resource "azurerm_network_interface" "drbd" {
  count                     = var.drbd_count
  name                      = "drbd-nic-${count.index}"
  location                  = var.az_region
  resource_group_name       = var.resource_group_name
  network_security_group_id = var.sec_group_id

  ip_configuration {
    name                          = "drbd-ip-configuration-${count.index}"
    subnet_id                     = var.network_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = element(var.host_ips, count.index)
    public_ip_address_id          = element(azurerm_public_ip.drbd.*.id, count.index)
  }

  tags = {
    workspace = terraform.workspace
  }
}

# drbd custom image. only available is drbd_image_uri is used

resource "azurerm_image" "drbd-image" {
  count               = var.drbd_image_uri != "" ? 1 : 0
  name                = "drbd-image"
  location            = var.az_region
  resource_group_name = var.resource_group_name

  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = var.drbd_image_uri
    size_gb  = "32"
  }

  tags = {
    workspace = terraform.workspace
  }
}

# drbd instances

resource "azurerm_virtual_machine" "drbd" {
  count                 = var.drbd_count
  name                  = "drbd-${count.index}"
  location              = var.az_region
  resource_group_name   = var.resource_group_name
  network_interface_ids = [element(azurerm_network_interface.drbd.*.id, count.index)]
  availability_set_id   = var.availability_set_id
  vm_size               = "Standard_D2s_v3"

  storage_os_disk {
    name              = "drbd-os-disk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    id        = var.drbd_image_uri != "" ? join(",", azurerm_image.drbd-image.*.id) : ""
    publisher = var.drbd_image_uri != "" ? "" : var.drbd_public_publisher
    offer     = var.drbd_image_uri != "" ? "" : var.drbd_public_offer
    sku       = var.drbd_image_uri != "" ? "" : var.drbd_public_sku
    version   = var.drbd_image_uri != "" ? "" : var.drbd_public_version
  }

  storage_data_disk {
    name              = "drbd-devices-${count.index}"
    caching           = "ReadWrite"
    create_option     = "Empty"
    disk_size_gb      = "10"
    lun               = "0"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "drbd0${count.index + 1}"
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